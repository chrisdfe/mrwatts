require 'rubygems'
require 'bundler'
require 'rspec'

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['test/*-spec.rb']
end


task :default => :spec