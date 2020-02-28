# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'editmode-rails/version'

Gem::Specification.new do |spec|
  spec.name          = "editmode"
  spec.version       = EditModeRails::VERSION
  spec.authors       = ["Tony Ennis"]
  spec.email         = ["ennis.tony@gmail.com"]
  spec.summary       = %q{Editmode allows you to turn plain text in your rails app into easily inline-editable bits of content that can be managed by anyone with no technical knowledge}
  spec.description       = %q{The Editmode gem allows you to include chunks from the Editmode platform in your rails views}
  spec.homepage      = "https://github.com/tonyennis145/editmode-rails"
  spec.license       = "MIT"

  spec.files = Dir["{app,lib,config}/**/*"] + ["Rakefile", "Gemfile", "README.md"]
  
  spec.add_dependency "bundler"
  spec.add_dependency "rake"
  spec.add_dependency "httparty"
  spec.add_dependency "redcarpet"

end