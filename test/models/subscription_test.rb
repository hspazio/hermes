require 'test_helper'

class SubscriptionTest < Minitest::Test
  context 'A Subscription' do
    should 'have a feed, a user and a callback url' do
      subscription = create(:subscription)

      assert subscription.valid?
      assert_kind_of User, subscription.user
      assert_kind_of Feed, subscription.feed
      assert subscription.callback_url.present?
    end

    should 'not have invalid callback url' do
      subscription = build(:subscription, callback_url: 'invalid.com/url')
      assert !subscription.valid?
      assert_equal 'is not a valid url', subscription.errors[:callback_url].first
    end

    should 'not have nil feed' do
      subscription = create(:subscription, feed: nil)
      assert_equal 'can\'t be blank', subscription.errors[:feed].first
    end

    should 'not have nil user' do
      subscription = create(:subscription, user: nil)
      assert_equal 'can\'t be blank', subscription.errors[:user].first
    end

    should 'have user subscribing to a feed only once' do
      sub1 = create(:subscription)
      sub2 = build(:subscription, user: sub1.user, feed: sub1.feed)

      assert !sub2.valid?
      assert_equal 'is already a subscriber of the feed', sub2.errors[:user].first
    end
  end
end