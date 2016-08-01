require 'test_helper'

class UserTest < Minitest::Test
  context 'A User' do
    should 'have a username and password' do
      user = build(:user)

      assert user.valid?
      assert_match(/username/, user.username)
      assert user.password.present?
    end

    should 'have non empty username' do
      user = create(:user, username: '')
      assert_equal 'can\'t be blank', user.errors[:username].first
    end

    should 'have valid username' do
      user = create(:user, username: 'a')
      assert_match(/is too short/, user.errors[:username].first)
    end

    should 'have a unique username' do
      user1 = create(:user, username: 'my_name')
      user2 = create(:user, username: 'my_name')
      assert_equal 'has already been taken', user2.errors[:username].first
    end

    should 'generate token' do
      user = build(:user)
      user.generate_token

      assert_match(/[a-f0-9]{32}/i, user.token)
    end
  end
end