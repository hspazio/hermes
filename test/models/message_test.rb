require 'test_helper'

class MessageTest < Minitest::Test
  context 'A Message' do
    should 'have a feed and a user' do
      message = create(:message)

      assert message.valid?
      assert_kind_of User, message.user
      assert_kind_of Feed, message.feed
    end

    should 'not have nil feed' do
      message = create(:message, feed: nil)
      assert_equal 'can\'t be blank', message.errors[:feed].first
    end

    should 'not have empty data' do
      message = create(:message, data: nil)
      assert_equal 'can\'t be blank', message.errors[:data].first

      message.data = ''
      assert_equal 'can\'t be blank', message.errors[:data].first
    end

    should 'have a json data' do
      message = create(:message, data: 'not a json')
      assert_equal 'is not a valid json', message.errors[:data].first
    end
  end
end