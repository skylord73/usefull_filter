# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
require File.expand_path('../lib/usefull_filter/version', __FILE__)

Gem::Specification.new do |s|
  s.authors          = ["Andrea Bignozzi"]
  s.email            = ["skylord73@gmail.com"]
  s.description      = "Describe Gem Here"
  s.summary          = "Describe Gem Here"
  
  s.files            = Dir["{app,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.rdoc", "CHANGELOG.md"]
  s.executables      = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files       = s.files.grep(%r{^(test|spec|features)/})
  s.name             = "usefull_filter"
  s.require_paths    = ["lib"]
  s.version          = UsefullFilter::VERSION
  
  s.add_dependency "rails", "3.0.9"
  
end

