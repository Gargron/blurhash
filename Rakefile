require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rake/extensiontask"

task :build => :compile

Rake::ExtensionTask.new("blurhash") do |ext|
  ext.name = "encode"
  ext.lib_dir = "lib/blurhash"
end

task :default => [:clobber, :compile, :spec]
