require File.expand_path("../lib/wikiwah/version", __FILE__)

Gem::Specification.new do |gem|
  
  gem.name = "wikiwah"
  gem.summary = "WikiWah turns text into HTML"
  gem.homepage = "http://github.com/mdub/wikiwah"
  gem.authors = ["Mike Williams"]
  gem.email = "mdub@dogbiscuit.org"

  gem.version = WikiWah::VERSION
  gem.platform = Gem::Platform::RUBY

  gem.require_path = "lib"
  gem.files = Dir["lib/**/*", "README.markdown", "LICENSE"]
  gem.test_files = Dir["test/**/*", "Rakefile"]
  
end
