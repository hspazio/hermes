require 'test_helper'

class SubscriptionTest < Minitest::Test
  context 'A Subscription' do
    should 'have a feed and a user' do
      subscription = create(:subscription)

      assert subscription.valid?
      assert_kind_of User, subscription.user
      assert_kind_of Feed, subscription.feed
    end

    should 'not have nil feed' do
      subscription = create(:subscription, feed: nil)
      assert_equal 'can\'t be blank', subscription.errors[:feed].first
    end

    should 'not have nil user' do
      subscription = create(:subscription, user: nil)
      assert_equal 'can\'t be blank', subscription.errors[:user].first
    end
  end
end