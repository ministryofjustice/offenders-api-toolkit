$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "offenders_api"
require "webmock/rspec"
require 'pry'

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }

WebMock.disable_net_connect!

RSpec.configure do |s|
  s.include(WebmockHelpers)
end
