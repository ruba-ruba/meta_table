desc "Creates a test rails app for the specs to run against"
task :setup do
  if File.exists? dir = "spec/dummy"
    puts "test app #{dir} already exists; skipping"
  else
    system "bundle exec rails new #{dir} -T -m spec/support/rails_template.rb --skip-bundle"
  end
end
