require "meta_table/version"
require 'meta_table/railtie'
require 'meta_table/model_additions' if defined?(Rails)
require 'rails'
require 'action_view'

module MetaTable

  # def self.included(base)
  #   base.extend(ClassMethods)
  #   base.send(:include, InstanceMethods)
  # end

  # module ClassMethods
    extend ActionView::Helpers::TextHelper 
    extend ActionView::Helpers::TagHelper
    extend ActionView::Context

    def self.get_data options, collection
      hash_data = collection.map do |record|
        options[:attributes].map do |attr|
          if record.respond_to?(attr)
            record.send attr
          else
            get_on_relation(record, attr)
          end
        end
      end
    end

    def self.get_on_relation(record, attr)
      values = attr.values.flatten
      key    = attr.keys.first
      values.map do |value|
        if ActiveRecord::Base.descendants.include?(record.send(key).class)
          record.send(key).send(:"#{value}")
        else
          record.send(key).try(:map, &:"#{value}")
        end
      end.join(',')
    end

    def self.render_table klass, options
      attributes = options[:attributes]
      actions    = options[:actions]
      collection = klass.all
      hash_data  = get_data(options, collection)
      content    = (render_top_header(actions) + render_data_table(attributes, hash_data))
      wrap_all(content)
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
      klass = attribute.class
      case klass
      when String
        attribute
      when Array || Fixnum
        attribute.to_s
      when TrueClass
        'yes'
      when FalseClass
        'no'
      when NilClass
        ''
      when Hash
        attribute.keys.first
      else
        attribute.to_s
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

  # end

  # module InstanceMethods
  # end
end