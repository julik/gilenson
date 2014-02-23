# coding: utf-8
$:.push File.expand_path("../lib", __FILE__)

require "bundler/gem_tasks"

require 'rake/testtask'
require "gilenson"

desc "Run all tests"
Rake::TestTask.new("test") do |t|
  t.libs << "test"
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
end

task :default => [ :test ]