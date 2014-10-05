require "meta_table/version"
require 'meta_table/railtie'
require 'meta_table/model_additions' if defined?(Rails)
require 'action_view'
require 'action_controller'


module MetaTable

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
    
    def self.get_data attributes, collection, actions
      hash_data = collection.map do |record|
        raw_data = attributes.map do |attr|
          if attr.is_a?(Symbol)
            record.send attr
          else
            fetch_rely_on_hash(record, attr)
          end
        end
        record_actions = make_record_actions(record, actions)
        raw_data << record_actions
      end
    end

    def self.guess_controller_name(record)
      "#{record.class.to_s.underscore.pluralize}"
    end

    def self.make_record_actions(record, actions)
      controller = guess_controller_name(record)
      actions.map do |action|
        if action.is_a?(Array)
          action_name      = action[0]
          namespace = action[1]
          controller_name  = "#{namespace}/#{controller}"
        end
        controller_name ||= controller
        action_name     ||= action
        # binding.pry
        route = Rails.application.routes.url_helpers.url_for({host: Rails.application.class::APP_URL,controller: controller_name, action: action_name, id: record.id})
        if action_name == :destroy
          link_to action_name, route, method: :delete, data: {:confirm => 'Are you sure?'}
        else
          link_to action_name, route
        end
      end.join(' ').html_safe
    end

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

    def self.render_table klass, options
      attributes    = options[:attributes] # modify_attributes(options[:attributes])
      relations     = nil # not implemented yet
      table_actions = options[:actions]
      top_actions   = options[:top_actions] # not implemented
      collection    = klass.all
      hash_data     = get_data(attributes, collection, table_actions)
      content       = (render_top_header(top_actions) + render_data_table(attributes, hash_data, table_actions))
      wrap_all(content)
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
        ''
      when 'Hash'
        render_table_header_attribute(attribute)
      else
        attribute.to_s
      end
    end

    def self.render_table_header_attribute(attribute)
      attribute[:label].presence || "#{attribute[:key]} - #{attribute[:method]}"
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