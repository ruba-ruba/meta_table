module MetaTable
  module ControllerAdditions
   
    def render_meta_table(table_options, options = {}) 
      MetaTable.initialize_meta(self, self.resource_class, table_options, options)
    end

    def meta_table(key, args, options)
      MetaTable.preinit_table(key, args, options)
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