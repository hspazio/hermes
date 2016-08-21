require 'sinatra/activerecord/rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs.push 'test'
  t.test_files = FileList['test/**/*_test.rb'].exclude('test/hermes_client_test.rb')
  t.warning = false
  t.verbose = false
end
 
task :default => :test
 
desc 'Generates a coverage report'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['test'].execute
end

namespace :db do
  task :load_config do
    require "./hermes"
  end
end
