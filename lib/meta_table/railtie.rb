module MetaTable
  class Railtie < Rails::Railtie
    initializer 'meta_table.model_additions' do
      ActiveSupport.on_load :active_record do
        include MetaTable::ModelAdditions
        extend  MetaTable::ModelAdditions
      end
    end
    initializer "meta_table.controller_additions" do
      ActiveSupport.on_load :action_controller do
        include MetaTable::ControllerAdditions
        extend  MetaTable::ControllerAdditions
      end
    end
    initializer "meta_table.controller_additions" do
      ActiveSupport.on_load :action_view do
        include MetaTable::ViewAdditions
        extend  MetaTable::ViewAdditions
      end
    end
    rake_tasks do
      load 'tasks/meta_table_tasks.rake'
    end
  end

end

