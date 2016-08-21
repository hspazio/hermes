require 'test_helper'
require_relative '../hermes_client'

class HermesClientTest < Minitest::Test
  context 'HermesClient' do
    setup do
      @client = HermesClient.new('http://localhost:9292')
    end

    should 'login' do
      assert_match /[a-f0-9]{32}/i, @client.login('fabio_pitino', '1234')
    end

    context 'logged in' do
      setup do
        @client.login('fabio_pitino', '1234')
      end

      should 'get feeds' do
	feeds = @client.feeds
	assert feeds.any?
	assert feeds.first[:id] > 0
	assert !feeds.first[:name].empty?
      end

      should 'get feed by id' do
        feed = @client.feed_by_id(141541649)
	assert feed[:id] > 0
	assert_equal 'ares', feed[:name]
      end

      should 'create feed' do
        feed = @client.create_feed(name: 'athena')
	assert feed[:id] > 0
	assert_equal 'athena', feed[:name]
      end
    end
  end
end
