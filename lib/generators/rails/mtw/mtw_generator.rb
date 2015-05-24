require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'

class Rails::MtwGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)
  argument :name, :type => :string, :default => ""

  def self.next_migration_number(path)
    ActiveRecord::Generators::Base.next_migration_number(path)
  end

  def create_migration_file
    migration_template "create_meta_table_views.rb", "db/migrate/create_meta_table_views.rb"
  end
end