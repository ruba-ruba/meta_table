$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "meta_table/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "meta_table"
  s.version     = MetaTable::VERSION
  s.authors     = ["@mrybak"]
  s.email       = ["email"]
  s.homepage    = "http://github.com"
  s.summary     = "MetaTable."
  s.description = "MetaTable."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.6"
  
  s.add_development_dependency "sqlite3"
end
