# Generated by cucumber-sinatra. (Tue Jun 05 13:54:21 +0300 2012)

ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '..', '..', 'src/client.rb')

require 'capybara'
require 'capybara/cucumber'
require 'rspec'

Capybara.app = Client

class ClientWorld
  include Capybara::DSL
  include RSpec::Expectations
  include RSpec::Matchers
end

World do
  ClientWorld.new
end