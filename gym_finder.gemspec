# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'gym_finder'
  spec.version = '1.0.1'
  spec.author = 'Jian Weihang'
  spec.email = 'tonytonyjan@gmail.com'
  spec.license = 'MIT'
  spec.summary = 'gym finder'
  spec.files = Dir['lib/**/*.{rb,json}']
  spec.executables << 'gym_finder'
  spec.add_runtime_dependency 'nokogiri'
  spec.add_runtime_dependency 'em-http-request'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
end
