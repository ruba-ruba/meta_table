class CreateMetaTableViews < ActiveRecord::Migration
  def self.up
    if !table_exists?(:meta_table_views)
      create_table :meta_table_views do |t|
        t.string  :name
        t.string  :source_class
        t.string  :source_controller
        t.boolean :hidden,   :default => false
        t.boolean :editable, :default => true
        t.integer :position
        t.text    :table_columns
        t.string  :conditions
        t.integer :created_by

        t.timestamps
      end
    end
  end

  def self.down
    drop_table :meta_table_views if table_exists?(:meta_table_views)
  end
end