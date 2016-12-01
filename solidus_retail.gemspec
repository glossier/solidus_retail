# encoding: UTF-8
$:.push File.expand_path('../lib', __FILE__)
require 'solidus_retail/version'

# rubocop:disable BlockLength
Gem::Specification.new do |s|
  s.name        = 'solidus_retail'
  s.version     = SolidusRetail::VERSION
  s.summary     = 'Solidus Extension to Support Retail Operations'
  s.description = "Sometimes online stores have point-of-sale operations as well. This extension brings your e-commerce and brick-and-mortar together under one umbrella."

  s.author    = ['Glossier', 'Dynamo']
  s.email     = ['gTEAM@glossier.com', 'hello@godynamo.com']
  # s.homepage  = 'http://www.example.com'

  s.files = Dir["{app,config,db,lib}/**/*", 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'shopify_api', '~> 4.0'
  s.add_dependency 'redcarpet'
  s.add_dependency 'solidus_core', '~> 1.4'
  s.add_dependency 'solidus_gateway' 

  s.add_development_dependency 'capybara', '~> 2.7'
  s.add_development_dependency 'poltergeist', '~> 1.10'
  s.add_development_dependency 'database_cleaner', '~> 1.5'
  s.add_development_dependency 'factory_girl', '~> 4.7'
  s.add_development_dependency 'rspec-rails', '~> 3.5'
  s.add_development_dependency 'rubocop', '~> 0.38'
  s.add_development_dependency 'rubocop-rspec', '~> 1.6'
  s.add_development_dependency 'simplecov', '~> 0.12'
  s.add_development_dependency 'sqlite3', '~> 1.3'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'vcr', '~> 3.0'
  s.add_development_dependency 'webmock', '~> 2.1'

  # Required for Solidus Gateway to work
  s.add_development_dependency "sass-rails"
  s.add_development_dependency "coffee-rails"
end
