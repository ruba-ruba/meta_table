module MetaTable
  module ControllerAdditions
    def render_meta_table(options)
      klass   = options[0]
      options = options[1]
      MetaTable.render_table(self, klass, options)
    end


    def self.included(base)
      base.include MetaTable
      base.include ActiveSupport::Inflector
      base.include ActionView::Helpers::UrlHelper
      base.include ActionView::Helpers::TagHelper
      base.include ActionView::Context
      
      base.class_eval do
        def make_erb(record,str)
          ERB.new(str).result(binding).html_safe
        end
      end
    end

    class ActionController::Base    
      def self.from_controller(klass, options={}, &block)
        binding.pry
      end
    end 
  end
end