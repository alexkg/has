$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "has/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "has"
  s.version     = Has::VERSION
  s.authors     = ["Alex Goldsmith"]
  s.email       = ["alex@katalyst.com.au"]
  s.homepage    = "http://github.com/alexkg/has"
  s.summary     = "Has macros for ActiveRecord."
  s.description = "Has packages up common patterns of Rails associations."

  s.files = [
    "app/models/has/has.rb",
    "lib/has/has.rb",
    "Rakefile",
    "README.rdoc",
    "MIT-LICENSE"
  ]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.0.0"
end
