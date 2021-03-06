#!/usr/bin/env gem build
# -*- encoding: utf-8 -*-

# Assume a typical dev checkout to fetch the current merb-core version
require File.expand_path('../../merb-core/lib/merb-core/version', __FILE__)

# Load this library's version information
require File.expand_path('../lib/merb-param-protection/version', __FILE__)

require 'date'

Gem::Specification.new do |gem|
  gem.name        = 'merb-param-protection'
  gem.version     = Merb::ParamProtection::VERSION.dup
  gem.date        = Date.today.to_s
  gem.authors     = ['Lance Carlson']
  gem.email       = 'lancecarlson@gmail.com'
  gem.homepage    = 'http://merbivore.com/'
  gem.description = 'Merb plugin that helps protecting sensible parameters'
  gem.summary     = 'Merb plugin that provides params_accessible and params_protected class methods'

  gem.has_rdoc = 'yard'
  gem.require_paths = ['lib']
  gem.files = Dir['Rakefile', '{lib,spec,docs}/**/*', 'README*', 'LICENSE*', 'TODO*'] & `git ls-files -z`.split("\0")

  # Runtime dependencies
  gem.add_dependency 'merb-core', "~> #{Merb::VERSION}"

  # Development dependencies
  gem.add_development_dependency 'rspec', '>= 1.2.9'
end
