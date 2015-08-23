module MetaTable
  module ControllerAdditions

    def meta_table(key, args, options)
      MetaTable.preinit_table(key, args, options)

      self.send(:define_singleton_method, "#{key}_columns") do
        self.instance_variable_set("@#{key}_columns", args)
      end

      self.send(:define_singleton_method, "#{key}_options") do
        self.instance_variable_set("@#{key}_options", options)
      end
    end



    def self.included(base)
      base.include MetaTable
      base.include ActiveSupport::Inflector
      base.include ActionView::Helpers::UrlHelper
      base.include ActionView::Helpers::TagHelper
      base.include ActionView::Context
      base.include ActionView::Helpers::AssetTagHelper
      base.include ActionView::Helpers::FormTagHelper

      base.class_eval do
        def make_erb(str, record=nil)
          ERB.new(str).result(binding).html_safe
        end
      end
    end

  end

  module ViewAdditions

    module InstanceMethods
    end

    def self.included(base)
      # base.extend         ClassMethods
      base.send :include, InstanceMethods
      base.class_eval do
        def sorting_arrow(attribute)
          if params["sort_by"] && attribute.to_s == params["sort_by"]
            case params["order"]
            when 'desc'
              raw '&#9660;'
            when 'asc'
              raw '&#9650;' 
            end
          end
        end

      end
    end
  end
end