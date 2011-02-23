require "bundler"
Bundler.setup

require "rspec"
require "rspec/core/rake_task"

Rspec::Core::RakeTask.new(:spec)

gemspec = eval(File.read(File.join(Dir.pwd, "cached_names.gemspec")))

task :build => "#{gemspec.full_name}.gem"

task :test => :spec

file "#{gemspec.full_name}.gem" => gemspec.files + ["cached_names.gemspec"] do
  system "gem build cached_names.gemspec"
  system "gem install cached_names-#{CachedNames::VERSION}.gem"
end

