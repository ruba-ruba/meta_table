require "meta_table/version"
require "meta_table/railtie"              if defined?(Rails)
require 'meta_table/model_additions'      if defined?(Rails)
require 'meta_table/controller_additions' if defined?(Rails)
require 'action_view'                     if defined?(Rails)
require 'action_controller'               if defined?(Rails)
require 'erb'

require 'meta_table/pagination'
require 'meta_table/fetch'
require 'meta_table/shared'


module MetaTable
  class Engine < ::Rails::Engine
  end

  include Fetch
  include Shared
  include Pagination

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

  def self.make_record_actions(record, actions)
    actions.map do |action|
      if action.is_a?(Array)
        action_name     = action[0]
        namespace       = action[1]
        classes         = action[2]
        controller_with_namespace = "#{namespace}/#{controller.controller_name}"
      end
      controller_with_namespace ||= controller.controller_name
      action_name ||= action
      route = Rails.application.routes.url_helpers.url_for({host: controller.request.host_with_port, controller: controller_with_namespace, action: action_name, id: record.id}) rescue nil
      if action_name == :destroy
        link_to action_name, route, method: :delete, data: {:confirm => 'Are you sure?'}
      elsif action.is_a?(String)
        controller.make_erb(action, record)
      else
        link_to action_name, route
      end
    end.join(' ').html_safe
  end

  # i suppose this shit should care about strings
  def self.implicit_render(record, attribute)
    renderer = attribute[:render_text]
    if renderer.is_a?(String) && erb?(renderer)
      controller.make_erb(renderer, record)
    elsif renderer.is_a? String
      eval(renderer)
    elsif renderer.is_a?(Array) && attribute[:key] == :actions # probably it is more than we need
      make_record_actions(record, renderer)
    else
      renderer
    end
  end

  def self.erb?(string)
    string.strip.start_with?('<%') && string.strip.ends_with?('%>')
  end

  def self.preinit_table(key, args, options)
    klass = options[:klass] || key
    define_method("render_#{key}_table") do |controller = self|
      MetaTable.initialize_meta(key, controller, args, options)
    end
  end

  def self.initialize_meta key, controller, attributes, options
    MetaTable.klass            = key.to_s.singularize.camelize.constantize
    MetaTable.controller       = controller
    MetaTable.model_attributes = attributes
    MetaTable.table_options    = options || {}
    MetaTable.collection       = initialize_collection
    render_mtw
  end

  def self.render_mtw
    top_actions = nil
    hash_data   = get_data(attriubtes_to_show)
    content     = (render_top_header(top_actions) + render_data_table(attriubtes_to_show, hash_data) + render_table_footer)
    wrap_all(content)
  end

  def self.model_attributes_keys
    if MetaTable.model_attributes.present?
      symbols = MetaTable.model_attributes.select { |a| a.is_a? Symbol }
      hashes  = MetaTable.model_attributes.select { |a| a.is_a? Hash }
      symbols + hashes.map { |h| h[:key] }
    else
      []
    end.flatten
  end

  def self.attriubtes_to_show
    dynamic_view_attributes || enabled_attributes
  end

  def self.dynamic_view_attributes
    if mtw = MetaTableView.find_by_id(controller.params[:table_view])
      model_attributes.select do |a|
        if a.is_a?(Hash)
          mtw.enabled_attributes.include?(a[:key].to_s)
        else
          mtw.enabled_attributes.include?(a.to_s)
        end
      end
    end
  end

  def self.enabled_attributes
    model_attributes.select { |attr| attr.is_a?(Symbol) || attr[:display] != false }
  end

  def self.initialize_collection
    scoped = klass.all
    scoped = eval("scoped.order('#{ordering}')") if ordering
    deep_send_with_object(scoped, table_options[:scope]) if table_options[:scope]
    scoped = basic_search(scoped)
    paginated_collection(scoped)
  end

  def self.paginated_collection(scoped)
    page       = controller.params[:page] || 1
    per_page   = table_options[:per_page] || 15
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
    str = []
    simple_searchable_columns.each do |column|
      str << "#{column} LIKE :search"
    end
    mega_string = str.join(' OR ')
    scoped = scoped.where("#{mega_string}", {search: "%#{controller.params[:basic_search]}%"})
  end

  def self.simple_searchable_columns
    searchable_attributes = model_attributes.select {|a| a.is_a?(Hash) && a[:searchable] == true}
    searchable_suggested_columns = searchable_attributes.map {|r| r[:key].to_s}
    klass.column_names & searchable_suggested_columns
  end

  def self.ordering
    order_column = controller.params[:sort_by]
    order_direction = controller.params[:order]
    "#{order_column} #{order_direction}" if klass.column_names.include?(order_column) && ['asc', 'desc'].include?(order_direction)
  end

  def self.wrap_all(content)
    content_tag(:div, nil, class: 'meta_wrapper') do
      content
    end
  end

  def self.render_data_table(attributes, hash_data)
    content_tag(:table, nil, class: "data_table") do
      render_table_header(attributes) + render_table_data(hash_data)
    end
  end

  def self.render_top_header top_actions
    content_tag(:div, nil, class: 'top_header_wrapper') do
      concat(render_simple_search_and_filter)
      concat(content_tag(:div, "", class: 'clearfix'))
    end + content_tag(:div, "", class: 'clearfix')
  end


  def self.render_simple_search_and_filter
    options_for_select = [['default', -1]] + MetaTableView.where(:source_controller => controller.class.name.to_s).for_user.positioned.collect{ |r| [r.name, r.id] }
    content_tag(:form, :method => 'get', id: 'meta_table_search_form') do
      concat(link_to 'create', "/meta_table/new?key=#{MetaTable.controller.class}", class: 'create_mtw_button')
      concat(controller.make_erb "<%= text_field_tag :basic_search, controller.params[:basic_search], class: 'meta_table_search_input' %>")
      concat(select_tag 'table_view', options_for_select(options_for_select, controller.params[:table_view]), onchange: "this.form.submit();")
    end
  end

  def self.render_table_footer
    content_tag(:div, nil, class: 'table_footer') do
      concat(render_pagination)
      concat(content_tag(:div, "", class: 'clearfix'))
    end
  end

  def self.render_table_data hash_data
    concat(content_tag(:tbody, nil) do
      hash_data.map do |row|
        concat(content_tag(:tr, nil) do
          row.map do |attribute|
            concat(content_tag(:td, nil) do
              render_attribute(attribute)
            end)
          end
        end)
      end
    end)
  end

  def self.render_attribute(attribute)
    case attribute.class.to_s
    when 'String'
      attribute
    when 'Array', 'Fixnum'
      attribute.to_s
    when 'Symbol' # this is part of header's => => => remove this to separate method
      attribute.to_s.try(:humanize)
    when 'TrueClass'
      'yes'
    when 'FalseClass'
      'no'
    when 'NilClass'
      nil
    when 'Hash'
      render_table_header_attribute_from_hash(attribute)
    else
      attribute.to_s
    end
  end

  def self.render_table_header_attribute_from_hash(attribute)
    attribute_name = header_attribute_name(attribute)
    if attribute[:sortable] == true
      link_to attribute_name, format_link_with_sortble(attribute)
    else
      attribute_name
    end
  end

  def self.header_attribute_name(attribute)
    if attribute.is_a?(Symbol)
      attribute
    elsif attribute[:label].present?
      attribute[:label]
    else
      attribute[:key]
    end.to_s.humanize # + I18n here
  end

  def self.format_link_with_sortble(attribute)
    attribute_name = header_attribute_name(attribute)
    current_url = controller.request.url
    direction = current_url.match(/sort_by=\w{1,}&\w{1,}=desc/).present? ? 'asc' : 'desc'
    if current_url.match('sort_by=\w')
      current_url.gsub(/sort_by=\w{1,}\&\w{1,}=(asc|desc)/, "sort_by=#{attribute[:key]}&order=#{direction}")
    elsif current_url.match('\?\w')
      "#{current_url}&sort_by=#{attribute[:key]}&order=#{direction}"
    else
      "#{current_url}?sort_by=#{attribute[:key]}&order=#{direction}"
    end
  end

  def self.render_table_header attributes
    concat(content_tag(:thead, nil) do  
      concat(content_tag(:tr, nil) do
        attributes.map do |attribute|
          concat(content_tag(:th, nil) do
            render_attribute(attribute)
          end)
        end
      end)
    end)
  end

  def method_missing(meth, *args, &block)
    if meth.to_s.match(/render_/) && meth.to_s.match(/_table/)
      'rock and handle this even before'
    else
      super meth, *args, &block
    end
  end

end