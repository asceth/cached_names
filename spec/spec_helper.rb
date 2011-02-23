require 'rubygems'
require 'bundler'
Bundler.setup

require 'rspec'
require 'cached_names'

RSpec.configure do |config|
  config.mock_with :rr
end

