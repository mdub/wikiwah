require 'bundler'

Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.test_files = FileList['test/**/*_tests.rb']
end

task :default => :test