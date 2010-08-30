require File.expand_path("../lib/wikiwah/version", __FILE__)

description = <<-EOF
WikiWah is a text-to-HTML converter, along the lines of Markdown.  

This isn't the markup language you're looking for.  
It offers no improvements on Markdown, Textile, etc.  
I'm packaging it as a gem only because I still have some legacy content in this format.
EOF

Gem::Specification.new do |gem|
  
  gem.name = "wikiwah"
  gem.summary = "WikiWah turns text into HTML"
  gem.description = description
  
  gem.homepage = "http://github.com/mdub/wikiwah"
  gem.authors = ["Mike Williams"]
  gem.email = "mdub@dogbiscuit.org"

  gem.version = WikiWah::VERSION
  gem.platform = Gem::Platform::RUBY

  gem.require_path = "lib"
  gem.files = Dir["lib/**/*", "README.markdown", "LICENSE"]
  gem.test_files = Dir["test/**/*", "Rakefile"]
  
end
