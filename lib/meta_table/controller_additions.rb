module MetaTable
  module ControllerAdditions
    def render_meta_table(options)
      MetaTable.initialize_meta(self, self.resource_class, options)
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
        def make_erb(record,str)
          ERB.new(str).result(binding).html_safe
        end
      end
    end

    class ActionController::Base    
      def self.from_controller(klass, options={}, &block)
        binding.pry
        p 'i\'ve opened this class'
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