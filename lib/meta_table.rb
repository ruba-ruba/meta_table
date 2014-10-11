require "meta_table/version"
require 'meta_table/railtie'
require 'meta_table/model_additions' if defined?(Rails)
require 'meta_table/controller_additions' if defined?(Rails)
require 'action_view'
require 'action_controller'

require 'meta_table/pagination'


module MetaTable
  class Engine < ::Rails::Engine
  end

  # def self.included(base)
  #   base.extend(ClassMethods)
  #   base.send(:include, InstanceMethods)
  # end

  # module ClassMethods
    extend ActiveSupport::Inflector
    extend ActionView::Helpers::UrlHelper
    extend ActionView::Helpers::TextHelper 
    extend ActionView::Helpers::TagHelper
    extend ActionView::Context

    mattr_accessor :hostname
    mattr_accessor :controller
    mattr_accessor :collection

    def self.get_data attributes, actions
      hash_data = collection.map do |record|
        raw_data = attributes.map do |attr|
          if attr.is_a?(Symbol)
            record.send attr
          else
            fetch_rely_on_hash(record, attr)
          end
        end
        raw_data << make_record_actions(record, actions) if actions.present?
        raw_data
      end
    end

    def self.guess_controller_name(record)
      "#{record.class.to_s.underscore.pluralize}"
    end

    def self.make_record_actions(record, actions)
      controller = guess_controller_name(record)
      actions.map do |action|
        if action.is_a?(Array)
          action_name     = action[0]
          namespace       = action[1]
          controller_name = "#{namespace}/#{controller}"
        end
        controller_name ||= controller
        action_name     ||= action
        route = Rails.application.routes.url_helpers.url_for({host: self.hostname ,controller: controller_name, action: action_name, id: record.id})
        if action_name == :destroy
          link_to action_name, route, method: :delete, data: {:confirm => 'Are you sure?'}
        else
          link_to action_name, route
        end
      end.join(' ').html_safe
    end


  # should be used for habtm hm hmt relations

            # def self.modify_attributes attributes
            #   attributes.inject([]) do |ary, attribute|
            #     ary << (needs_perform?(attribute) ? modify_attribute(attribute) : attribute)
            #   end.flatten
            # end

            # def self.needs_perform?(attribute)
            #   attribute.kind_of?(Hash)
            # end

            # def self.modify_attribute(attribute)
            #   attribute # not implemented yet
            # end

    def self.fetch_rely_on_hash(record, attribute)
      attr = attribute[:key]
      relation = record.send(attr)
      method   = attribute[:method]
      if method && ActiveRecord::Base.descendants.include?(relation.class)
        relation.send(:"#{method}")
      else
        relation
      end
    end

    def self.render_table controller, klass, options
      MetaTable.controller = controller
      MetaTable.collection = initialize_collection(klass, options[:table_options])
      MetaTable.hostname   = controller.request.host_with_port
      attributes    = options[:attributes] # modify_attributes(options[:attributes])
      relations     = nil # not implemented yet
      table_actions = options[:actions]
      top_actions   = options[:top_actions] # not implemented
      table_options = options[:table_options]
      hash_data     = get_data(attributes, table_actions)
      content       = (render_top_header(top_actions) + render_data_table(attributes, hash_data, table_actions) + render_table_footer)
      wrap_all(content)
    end

    def self.initialize_collection(klass, table_options)
      page = controller.params[:page] || 1
      order_column = controller.params[:sort_by]
      order_direction = controller.params[:order]
      order = "#{order_column} #{order_direction}"
      # binding.pry\
      per_page = (table_options && table_options[:per_page]) || 10
      scope = ""
      scope << table_options[:scope] if table_options && table_options[:scope].present?
      scope << "." if controller.params[:sort_by].present? && table_options[:scope].present?
      scope << "order('#{order}')" if order.strip.present?
      collection = if scope.present?
        eval "klass.#{scope}.page(page).per(#{per_page})"
      else
        klass.page(page).per(per_page)
      end
      @@collection = collection
    end

    def self.wrap_all(content)
      content_tag(:div, nil, class: 'meta_wrapper') do
        content
      end
    end

    def self.render_data_table(attributes, hash_data, table_actions)
      content_tag(:table, nil, class: "data_table") do
        render_table_header(attributes, table_actions) + render_table_data(hash_data)
      end
    end

    def self.render_top_header actions
      content_tag(:div, nil, class: 'top_header_wrapper') do
      end
    end

    def self.render_table_footer
      content_tag(:div, nil, class: 'table_footer') do
        concat(Pagination.render_pagination)
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
      klass = attribute.class.to_s
      case klass
      when 'String'
        attribute
      when 'Array' || 'Fixnum' || 'Symbol'
        attribute.to_s
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
      attribute[:label].presence || (attribute[:method].present? ? "#{attribute[:key].to_s.humanize} - #{attribute[:method]}" : attribute[:key].to_s.humanize)
    end

    def self.format_link_with_sortble(attribute)
      attribute_name = header_attribute_name(attribute)
      current_url = controller.request.url
      # binding.pry 
      direction = current_url.match(/sort_by=\w{1,}&\w{1,}=desc/).present? ? 'asc' : 'desc'
      if current_url.match('sort_by=\w')
        current_url.gsub(/sort_by=\w{1,}\&\w{1,}=(asc|desc)/, "sort_by=#{attribute[:key]}&order=#{direction}")
      elsif current_url.match('\?\w')
        "#{current_url}&sort_by=#{attribute[:key]}&order=#{direction}"
      else
        "#{current_url}?sort_by=#{attribute[:key]}&order=#{direction}"
      end
    end

    def self.render_table_header attributes, table_actions
      attributes << "Actions" if table_actions.present? && table_actions.any?
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

  # end

  # module InstanceMethods
  # end
end