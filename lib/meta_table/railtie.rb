module MetaTable
  class Railtie < Rails::Railtie
    initializer 'meta_table.model_additions' do
      ActiveSupport.on_load :active_record do
        extend ModelAdditions
      end
    end
    initializer "meta_table.controller_additions" do
      ActiveSupport.on_load :action_controller do
        include MetaTable::ControllerAdditions # ActiveSupport::Concern
        extend  MetaTable::ControllerAdditions
      end
    end
    initializer "meta_table.controller_additions" do
      ActiveSupport.on_load :action_view do
        include MetaTable::ViewAdditions # ActiveSupport::Concern
        extend  MetaTable::ViewAdditions
      end
    end
  end
end

