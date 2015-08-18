# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chunks/version'

Gem::Specification.new do |spec|
  spec.name          = "chunks"
  spec.version       = Chunks::VERSION
  spec.authors       = ["Tony Ennis"]
  spec.email         = ["ennis.tony@gmail.com"]
  spec.summary       = %q{Chunks allows you to turn plain text in your rails app into easily inline-editable chunks that can be managed by anyone with no technical knowledge}
  spec.description       = %q{Chunks allows you to turn plain text in your rails app into easily inline-editable chunks that can be managed by anyone with no technical knowledge}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files = Dir["{app,lib,config}/**/*"] + ["Rakefile", "Gemfile", "README.md"]

  # spec.files         = `git ls-files -z`.split("\x0")
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  # spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  # spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "github-markdown"
  spec.add_development_dependency "httparty"

end