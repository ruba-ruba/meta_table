desc "Copy"
namespace :meta_table do

  task :generate_data_view_table do
    timestamp = "#{Time.now}".gsub(/-|:| |\D/, '')[0..13]
    source = File.join(Gem.loaded_specs["meta_table"].full_gem_path, 'lib', 'tasks', 'create_meta_table_views.rb')
    target = File.join(Rails.root, 'db', 'migrate', "#{timestamp}_create_meta_table_views.rb")
    FileUtils.cp_r source, target
    puts 'don\'t forget to migrate changes'
  end

end
