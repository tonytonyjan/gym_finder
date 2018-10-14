# frozen_string_literal: true

require 'rubygems/package_task'
require 'rake/testtask'

task default: :test

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

spec = Gem::Specification.load("#{__dir__}/gym_finder.gemspec")
Gem::PackageTask.new(spec).define
