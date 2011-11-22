# -*- encoding: utf-8 -*-
# -*- ruby -*-
$KCODE = 'u' if RUBY_VERSION < '1.9.0'

require 'rubygems'
require 'jeweler'
require './lib/gilenson'

Jeweler::Tasks.new do |gem|
  gem.version = Gilenson::VERSION
  gem.name = "gilenson"
  gem.summary = "Гиленсон - улучшайзер русской типографики"
  gem.email = "me@julik.nl"
  gem.homepage = "http://github.com/julik/gilenson"
  gem.authors = ["Julik Tarkhanov"]
  gem.license = 'MIT'
  gem.executables = %w( gilensize )
  
  # Deps
  gem.add_development_dependency "jeweler"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "maruku", "~> 0.6"
  gem.add_development_dependency  "RedCloth", "~> 4.2"
  gem.add_development_dependency "bluecloth", "~> 2.0"
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
desc "Run all tests"
Rake::TestTask.new("test") do |t|
  t.libs << "test"
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
end

task :default => [ :test ]

# vim: syntax=ruby