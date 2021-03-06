# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/deploylock/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-deploylock"
  spec.version       = Capistrano::Deploylock::VERSION
  spec.authors       = ["tetuyoko"]
  spec.email         = ["tyokoyama53@gmail.com"]
  spec.summary       = %q{lock set to deployed server for 1 day.}
  spec.description   = %q{lock set to deployed server for 1 day.}
  spec.homepage      = "https://github.com/tetuyoko/capistrano-deploylock"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.1.0'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_dependency "capistrano", '~> 2.15.6'
end
