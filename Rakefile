require 'rubygems'
require 'bundler'
require 'rake'

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['test/mrwatts-spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'test/mrwatts-spec.rb'
  spec.rcov = true
end

task :default => :spec