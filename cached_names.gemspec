$:.push File.expand_path("../lib", __FILE__)
require "cached_names/version"

Gem::Specification.new do |s|
  s.name        = "cached_names"
  s.version     = CachedNames::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John 'asceth' Long", "Jason Dew"]
  s.email       = ["jasondew@gmail.com", "machinist@asceth.com"]
  s.homepage    = "http://github.com/jasondew/cached_names"
  s.summary     = "Cached names of static data for use in selects"
  s.description = "A gem for caching static data for use in selects"

  s.rubyforge_project = "cached_names"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rr'
end

