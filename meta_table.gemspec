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

  s.add_dependency('kaminari', '~> 0.16.1')
end
