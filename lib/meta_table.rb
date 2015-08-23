require 'uri'
require 'meta_table/version'
require 'meta_table/railtie'              if defined?(Rails)
require 'meta_table/model_additions'      if defined?(Rails)
require 'meta_table/controller_additions' if defined?(Rails)
require 'action_view'                     if defined?(Rails)
require 'action_controller'               if defined?(Rails)
require 'erb'

require 'meta_table/shared'
require 'meta_table/ui_helpers'

require 'kaminari'

module MetaTable
  class NoAttributesError < StandardError
  end
  class Engine < ::Rails::Engine
  end

  include Shared
  include UiHelpers

  extend ActiveSupport::Inflector
  extend ActionView::Helpers::UrlHelper
  extend ActionView::Helpers::TextHelper
  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::FormTagHelper
  extend ActionView::Helpers::FormOptionsHelper
  extend ActionView::Context

  mattr_accessor :klass
  mattr_accessor :controller
  mattr_accessor :collection
  mattr_accessor :table_options
  mattr_accessor :model_attributes

  def self.current_url
    controller.request.url
  end

  def self.make_record_actions(record, actions)
    actions.map do |action|
      if action.is_a?(Array)
        action_name, namespace = action
        controller_with_namespace = "#{namespace}/#{controller.controller_name}"
      end
      controller_with_namespace ||= controller.controller_name
      action_name ||= action
      route = Rails.application.routes.url_helpers.url_for({controller: controller_with_namespace, action: action_name, id: record.id, only_path: true}) rescue nil
      if action_name == :destroy
        link_to action_name, route, method: :delete, data: {:confirm => 'Are you sure?'}
      elsif action.is_a?(String)
        controller.make_erb(action, record)
      else
        link_to action_name, route
      end
    end.join(' ').html_safe
  end

  def self.implicit_render(record, attribute)
    if renderer = attribute[:render_text]
      if renderer.is_a?(String) && erb?(renderer)
        controller.make_erb(renderer, record)
      elsif renderer.is_a? String
        eval(renderer) rescue "caught exception #{$!}!"
      elsif renderer.is_a?(Array) && attribute[:key] == :actions
        make_record_actions(record, renderer)
      else
        renderer
      end
    else
      record.deep_send(attribute[:key])
    end
  end

  def self.erb?(string)
    string.strip.start_with?('<%') && string.strip.ends_with?('%>')
  end

  def self.preinit_table(key, args, options)
    klass = options[:klass] || key
    define_method("render_#{key.to_s.pluralize}_table") do |controller = self|
      MetaTable.initialize_meta(key, controller, args, options)
    end
  end

  def self.initialize_meta key, controller, attributes, options
    MetaTable.klass            = key.to_s.singularize.camelize.constantize
    MetaTable.controller       = controller
    MetaTable.model_attributes = attributes
    MetaTable.table_options    = options
    MetaTable.collection       = initialize_collection
    render_mtw
  end

  def self.render_mtw
    self.controller.render '/meta_table_views/index', locals: locals
  end

  def self.locals
    {header: header, content: content, footer: footer, collection: collection}
  end

  # table content
  # table content

  def self.header
    {link_to_new_record: link_to_new_record}
    # simple_search_and_filter: simple_search_and_filter
  end

  def self.content
    # {current_attributes: attributes_to_show, collection: collection}
    attributes = self.current_attributes
    collection = self.collection
    content = Object.new()
    content.define_singleton_method(:current_attributes) {attributes}
    content.define_singleton_method(:collection)         {collection}
    content
  end

  def self.footer
    {per_page_choises: per_page_choises}
  end

  # table content
  # table content

  def self.keys_for(params = {})
    if params[:mtw].is_a?(MetaTableView) && params[:mtw].persisted?
      return params[:mtw].table_columns.keys.map(&:to_sym)
    end 

    columns = params[:controller_name].constantize.send("#{params[:table_for]}_columns")
    if columns.any?
      symbols = columns.select { |a| a.is_a? Symbol }
      hashes  = columns.select { |a| a.is_a? Hash }
      ary = symbols + hashes.map { |h| h[:key] }
    else
      raise NoAttributesError.new
    end
  end

  def self.current_attributes
    dynamic_view_attributes || enabled_attributes
  end

  def self.normalized_attribute(attribute)
    attribute.is_a?(Hash) ? attribute : {key: attribute}
  end

  def self.normalized_attributes
    model_attributes.map{|a| normalized_attribute(a)}
  end

  def self.dynamic_view_attributes
    return nil unless mtw = MetaTableView.find_by_id(controller.params[:table_view])
    selected = []
    mtw.enabled_attributes.keys.each do |key|
      selected << normalized_attributes.select{|a| a[:key].to_s == key}
    end
    selected.flatten
  end

  def self.enabled_attributes
    normalized_attributes.select { |attr| attr[:display] != false }
  end

  def self.initialize_collection
    scoped = klass.all # what about scoped in rails 3 ???
    scoped = scoped.includes(table_options[:includes]) if table_options[:includes]
    scoped = eval("scoped.order('#{ordering}')") if ordering
    scoped = deep_send_with_object(scoped, table_options[:scope]) if table_options[:scope]
    scoped = basic_search(scoped)
    paginated_collection(scoped)
  end

  def self.normalize_current_page scoped
    page = controller.params[:page] || 1
    page = page.to_i - 1 if page.to_i > 1 && scoped.page(page).per(per_page).blank? # normalize page
    page
  end

  def self.per_page
    controller.params[:per_page] || per_page_choises.first
  end

  def self.paginated_collection(scoped)
    # useless assigment ???
    page       = normalize_current_page(scoped)
    collection = scoped.page(page).per(per_page)
  end

  def self.basic_search(scoped)
    if controller.params[:basic_search]
      execute_search(scoped)
    else
      scoped
    end
  end

  def self.execute_search(scoped)
    str =
      simple_searchable_columns.map do |column|
        "#{column} LIKE :search"
      end
    mega_string = str.join(' OR ')
    scoped.where("#{mega_string}", {search: "%#{controller.params[:basic_search]}%"})
  end

  def self.simple_searchable_columns
    searchable_attributes = model_attributes.select {|a| a.is_a?(Hash) && a[:searchable] == true}
    searchable_suggested_columns = searchable_attributes.map {|r| r[:key].to_s}
    klass.column_names & searchable_suggested_columns
  end

  def self.order_direction
    controller.params[:order]
  end

  def self.order_column
    controller.params[:sort_by]
  end

  def self.ordering
    "#{order_column} #{order_direction}" if klass.column_names.include?(order_column) && ['asc', 'desc'].include?(order_direction)
  end

  def self.views_for_controller
    [['default', -1]] + MetaTableView.views_for_controller(self.controller.class.to_s)
  end

  def self.link_to_new_record
    "#{controller.request.url}/new"
  end

  def self.per_page_choise
    controller.params[:per_page].present? ? controller.params[:per_page].to_i : per_page_choises.first
   end

  def self.per_page_choises
    table_options[:per_page_choises].presence || [5,15,30]
  end

  def self.render_attribute(attribute)
    case attribute.class.to_s
    when 'String', 'Array', 'Fixnum'
      attribute.to_s
    when 'Symbol' # this is part of header's => => => remove this to separate method
      attribute.to_s.try(:humanize)
    when 'TrueClass'
      'Yes'
    when 'FalseClass'
      'No'
    when 'NilClass'
      nil
    else
      attribute
    end
  end

  def self.render_header_attribute(attribute)
    attr_name = header_attribute_name(attribute)
    render_table_header_attribute_from_hash(attribute, attr_name)
  end

  def self.render_table_header_attribute_from_hash(attribute, attr_name)
    if klass.column_names.include?(attribute[:key].to_s)
      link_to attr_name, format_link_with_sortble(attribute[:key]), remote: true
    else
      attr_name
    end
  end

  def self.header_attribute_name(attribute)
    if attribute[:label].present?
      attribute[:label]
    else
      attribute[:key]
    end.to_s.humanize # + I18n here
  end

  def self.format_link_with_sortble(attr)
    symbol = attr.to_sym
    direction = current_url.match(/sort_by=\w{1,}&\w{1,}=asc/).present? ? 'desc': 'asc'
    pattern   = "sort_by=#{symbol}&order=#{direction}"
    if current_url.match('sort_by=\w')
      current_url.gsub(/sort_by=\w{1,}\&\w{1,}=(asc|desc)/, "#{pattern}")
    elsif current_url.match('\?\w')
      "#{current_url}&#{pattern}"
    else
      "#{current_url}?#{pattern}"
    end
  end

  def method_missing(meth, *args, &block)
    if meth.to_s.match(/render_/) && meth.to_s.match(/_table/)
      "looks like you use #{meth} method, but you need something like render_(yours_meta_table_key)_table"
    else
      super meth, *args, &block
    end
  end
end
