ENV['RACK_ENV'] = 'test'

require 'bundler'
Bundler.require :test

require 'json'
require 'minitest/autorun'
require 'factories'
require 'sidekiq/api'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

require_relative '../hermes'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'test'
    command_name 'Mintest'
  end
end

module TestHelper
  def json_parse(json)
    HashWithIndifferentAccess.new(JSON.parse(json))
  end
end

class Minitest::Test
  def around(&block)
    ActiveRecord::Base.connection.transaction do
      block.call
      raise ActiveRecord::Rollback
    end
  end
end