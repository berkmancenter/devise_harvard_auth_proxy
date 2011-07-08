require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the devise_imapable plugin.'
Rake::TestTask.new(:test) do |t|
  # t.libs << 'lib'
  # t.libs << 'test'
  # t.pattern = 'test/**/*_test.rb'
  # t.verbose = true
  puts <<-eof

*** NOTICE ***

All tests are done in the sample Rails app. 

Please go to test/rails_app and run the tests there. 

Make sure to bundle install and rake db:migrate

  eof
end

desc 'Generate documentation for the devise_harvard_auth_proxy plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'DeviseHarvardAuthProxy'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "devise_harvard_auth_proxy"
    gemspec.summary = "Harvard Auth Proxy authentication module for Devise"
    gemspec.description = "Harvard Auth Proxy module for Devise"
    gemspec.email = "djcp@cyber.law.harvard.edu"
    gemspec.homepage = "http://github.com/berkmancenter/devise_harvard_auth_proxy"
    gemspec.authors = ["Dan Collis-Puro"]
    gemspec.add_runtime_dependency "devise", "~> 1.4.0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
