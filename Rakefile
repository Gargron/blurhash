require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rake/extensiontask"

task :build => :compile

Rake::ExtensionTask.new("blurhash") do |ext|
  ext.name = "blurhash_ext"
end

task :default => [:clobber, :compile, :spec]
