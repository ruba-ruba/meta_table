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
        def from_view
        end
      end
    end
  end
end