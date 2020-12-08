require 'date'
require_relative 'util/sem_ver'

include SemVer

Gem::Specification.new do |s|
  s.name        = 'hacienda'
  s.version     = SemVer.version_from_git
  s.date        = Date.today.to_s
  s.summary     = 'Hacienda is a RESTful service to manage content'
  s.description = 'Hacienda is a RESTful service to manage content'
  s.authors     = ['Thoughtworks']
  s.email       = 'www-devs@thoughtworks.com'
  s.files       = %w(lib/hacienda_service.rb lib/hacienda/tasks.rb lib/hacienda/test_support.rb config/config_loader.rb) + Dir['app/**/*.rb'] +  Dir['spec/**/*.rb'] + Dir['rake/tasks/*']
  s.homepage    =
      'http://rubygems.org/gems/hola'
  s.license       = 'AGPL'

  s.add_dependency 'sinatra',         '~> 1.4.8'
  s.add_dependency 'sinatra-contrib', '~> 1.4.7'
  s.add_dependency 'json',            '~> 1.8.6'
  s.add_dependency 'multi_json'
  s.add_dependency 'octokit',         '~> 2.5.1'
  s.add_dependency 'rugged',          '~> 0.27.0'
  s.add_dependency 'unicorn',         '~> 4.8.3'

  s.add_development_dependency 'thin',        '~> 1.7.2'
  s.add_development_dependency 'rake',        '~> 10.1.0'
  s.add_development_dependency 'rspec',       '~> 2.14.1'
  s.add_development_dependency 'faraday',     '~> 0.8.7'
  s.add_development_dependency 'rack-test',   '~> 0.6.2'
  s.add_development_dependency 'simplecov',   '~> 0.13.0'
  s.add_development_dependency 'geminabox',   '~> 0.13.5'
end
