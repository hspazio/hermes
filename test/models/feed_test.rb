require 'test_helper'

class FeedTest < Minitest::Test
  context 'A Feed' do
    should 'have a name and a created_at field' do
      feed = create(:feed)
      assert_match(/feed/, feed.name)
      assert !feed.created_at.nil?
    end

    should 'belong to a user' do
      feed = build(:feed)
      assert feed.valid?
      assert feed.user
    end

    should 'have a valid name' do
      feed = build(:feed, name: nil)

      assert !feed.valid?
      assert feed.errors[:name].any?

      feed = build(:feed, name: 'f')
      assert !feed.valid?
      assert feed.errors[:name].any?
    end

    should 'have timestap fields' do
      feed = create(:feed)

      assert feed.created_at.present?
      assert feed.updated_at.present?
    end
  end
end