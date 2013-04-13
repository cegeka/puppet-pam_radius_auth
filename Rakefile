require 'rake'
require 'rspec/core/rake_task'
require 'puppet-lint/tasks/puppet-lint'

RSpec::Core::RakeTask.new(:spec) { |t| t.pattern = 'spec/*/*_spec.rb' }

task :default => [:spec, :lint]
