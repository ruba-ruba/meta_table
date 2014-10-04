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
          record.send(attr)
        end
      end
    end

    def self.render_table klass, options
      attributes = options[:attributes]
      collection = klass.all
      hash_data  = get_data(options, collection)
      content_tag(:table, nil, class: "meta_table") do
        render_data_headers(attributes) + render_data_table(hash_data)
      end
    end

    def self.render_data_table hash_data
      concat(content_tag(:tbody, nil) do
        hash_data.map do |row|
          concat(content_tag(:tr, nil) do
            row.map do |attribute|
              concat(content_tag(:td, nil) do
                attribute
              end)
            end
          end)
        end
      end)
    end

    def self.render_data_headers attributes
      concat(content_tag(:thead, nil) do  
        concat(content_tag(:tr, nil) do
          attributes.map do |attribute|
            concat(content_tag(:th, nil) do
              attribute.to_s
            end)
          end
        end)
      end)
    end

  # end

  # module InstanceMethods
  # end
end