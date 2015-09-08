$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "meta_table/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "meta_table"
  s.version     = MetaTable::VERSION
  s.authors     = ["@mrybak"]
  s.email       = ["email"]
  s.homepage    = "https://github.com/ruba-ruba/meta_table"
  s.summary     = "MetaTable."
  s.description = "MetaTable."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'kaminari',                     '~> 0.16.1'
  s.add_dependency 'rails',                        '>= 3.2', '< 5.0'
  s.add_dependency 'jquery-rails',                 '~> 3.1.0'
  s.add_dependency 'jquery-ui-rails',              '~> 5.0.0'

   
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency "rspec",            '~> 3.3.0'
  s.add_development_dependency "rspec-nc"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency "pry-remote"
  s.add_development_dependency "pry-nav"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-byebug"

  # there is a way to simulate rails engene by using
  s.add_development_dependency 'combustion', '~> 0.5.3'
end
