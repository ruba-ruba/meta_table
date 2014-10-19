module MetaTable
  module ControllerAdditions
    def render_meta_table(options)
      klass   = options[0]
      options = options[1]
      MetaTable.render_table(self, klass, options)
    end

    class ActionController::Base    
      def self.from_controller(klass, options={}, &block)
        # nothing here
      end
    end 
  end
end