require File.expand_path '../test_helper.rb', __FILE__

class HermesTest < MiniTest::Test
  include Rack::Test::Methods
  include TestHelper

  def app
    Hermes
  end

  def assert_not_found
    assert_equal 404, last_response.status
    assert_equal 'Record not found', JSON.parse(last_response.body)['error']
  end

  context 'User not logged in' do
    context 'POST /login' do
      should 'authenticate with correct username and password' do
        user = create(:user)
        post '/login', username: user.username, password: user.password

        assert_equal 201, last_response.status 
        resp = JSON.parse(last_response.body)
        assert_match /[a-f0-9]{32}/i, resp['token']
      end

      should 'return not_found if username does not exist' do
        post '/login', username: 'dunno', password: 'dunnoeither'
        assert_equal 404, last_response.status
        assert_equal "User 'dunno' not found", JSON.parse(last_response.body)['error']
      end

      should 'return bad_request if either username or password are missed' do
        post '/login', username: 'dunno'
        assert_equal 400, last_response.status
        assert_equal 'Missed required params username and password', JSON.parse(last_response.body)['error']

        post '/login', password: 'dunnoeither'
        assert_equal 400, last_response.status
        assert_equal 'Missed required params username and password', JSON.parse(last_response.body)['error']
      end
    end

    context 'GET /users' do
      should 'return unauthorized error if not authenticated' do
        get '/users'

        assert_equal 401, last_response.status
        assert_equal 'Unauthorized access. Please login', JSON.parse(last_response.body)['error']
      end

      should 'returns list of users if access token provided' do
        get '/users', {}, { 'Authorization' => 'Token token=a47a8e54b11c4de5a4a351734c80a14b' }
        assert_equal 200, last_response.status
      end

      should 'returns unauthorized error if wrong access token provided' do
        get '/users', {}, { 'Authorization' => 'Token token=a47a8e54b1' }
        assert_equal 401, last_response.status
        assert_equal 'Unauthorized access. Please login', JSON.parse(last_response.body)['error']
      end
    end
  end

  context 'User logged in' do
    setup do
      @user = User.find_by(username: 'fabio_pitino')
      @headers = { 'Authorization' => "Token token=#{@user.token}", 
                   'Content-Type' => 'application/json' }
    end

    context 'GET /users' do
      setup do
        5.times { create(:user) }
      end
     
      should 'list all users' do
        get '/users', {}, @headers

        assert_equal 200, last_response.status
        JSON.parse(last_response.body).each do |user|
          assert user['username']
          assert_operator 0, :<, user['id']
          assert !user['password'].present?
          assert !user['password_digest'].present?
        end 
      end
    end

    context 'GET /users/:id' do
      should 'show user' do
        get "/users/#{@user.id}", {}, @headers

        assert_equal 200, last_response.status
        result = JSON.parse(last_response.body)
        assert_match(/^fabio_pitino/, result['username'])
        assert_operator 0, :<, result['id']
        assert !result['password'].present?
        assert !result['password_digest'].present?
      end

      should 'return not_found if user does not exist' do
        get '/users/999999', {}, @headers
        assert_not_found
      end
    end

    context 'GET /feeds' do
    	should 'list all feeds' do
    	  create(:feed)	
        get '/feeds', {}, @headers

        assert last_response.ok?
        JSON.parse(last_response.body).each do |feed|
          assert_match(/feed/, feed['name'])
          assert !feed['created_at'].nil?
        end
    	end
    end

    context 'GET /feeds/:feed_id' do
    	should 'show a valid feed by id' do
    	  feed = create(:feed)
        get "/feeds/#{feed.id}", {}, @headers

        assert last_response.ok?
        data = JSON.parse(last_response.body)

        assert_equal feed.id, data['id']
        assert_equal feed.name, data['name']
        assert_equal feed.user_id, data['user_id']
    	end

    	should 'return not_found for invalid feed id' do
        get '/feeds/999999', {}, @headers
        assert_not_found
    	end
    end

    context 'POST /feeds' do
      should 'create a new feed' do
        post '/feeds', { name: 'test_feed' }, @headers

        assert_equal 201, last_response.status
        result = JSON.parse(last_response.body)
        assert_equal 'test_feed', result['name']
        assert result['id'].present?
        assert_equal @user.id, result['user_id']
        assert result['created_at'].present?
        assert result['updated_at'].present?
      end

      should 'not create a feed if name is not provided' do
        post '/feeds', {}, @headers

        assert_equal 400, last_response.status
        result = JSON.parse(last_response.body)
        assert_equal 'Parameter \'name\' must be provided', result['error']
      end

      should 'not create a feed if name is too short' do
        post '/feeds', { name: 'f' }, @headers

        assert_equal 400, last_response.status
        result = JSON.parse(last_response.body)
        assert_match(/name is too short/i, result['error'])
      end
    end

    context 'GET /feeds/:feed_id/subscriptions' do
      setup do
        @feed = create(:feed)
      end

      should 'list all subscriptions for a feed' do  
        5.times { create(:subscription, feed: @feed) }

        get "/feeds/#{@feed.id}/subscriptions", {}, @headers

        assert_equal 200, last_response.status
        results = JSON.parse(last_response.body)
        results.each do |subscription| 
          assert subscription['id'] > 0
          assert subscription['feed_id'] > 0
          assert subscription['user_id'] > 0
          assert subscription['callback_url'].present?
          assert subscription['created_at'].present?
          assert subscription['updated_at'].present?
        end
      end

      should 'return an empty array if there are no subscriptions' do
        get "/feeds/#{@feed.id}/subscriptions", {}, @headers

        assert_equal 200, last_response.status
        assert JSON.parse(last_response.body).empty?
      end

      should 'return not_found if feed does not exist' do
        get "/feeds/#{@feed.id + 1}/subscriptions", {}, @headers

        assert_equal 404, last_response.status
      end
    end

    context 'POST /feeds/:feed_id/subscriptions' do
      setup do
        @feed = create(:feed)
      end

      should 'successfully subscribe to a feed' do
        callback_url = 'https://mysite.com/callbacks'
        post "/feeds/#{@feed.id}/subscriptions", { callback_url: callback_url }, @headers

        assert_equal 201, last_response.status
        result = JSON.parse(last_response.body)
        assert_equal @feed.id, result['feed_id']
        assert_equal @user.id, result['user_id']
        assert_equal callback_url, result['callback_url']
      end

      should 'not subscribe to a feed without callback_url' do
        post "/feeds/#{@feed.id}/subscriptions", {}, @headers

        assert_equal 400, last_response.status
        assert_equal "Callback url can't be blank", JSON.parse(last_response.body)['error']

        post "/feeds/#{@feed.id}/subscriptions", { callback_url: '' }, @headers

        assert_equal 400, last_response.status
        assert_equal "Callback url can't be blank", JSON.parse(last_response.body)['error']
      end
    end

    context 'GET /subscriptions/:id' do
      should 'show a subscription' do
        subscription = create(:subscription, user: @user)
        get "/subscriptions/#{subscription.id}", {}, @headers

        assert_equal 200, last_response.status
        result = JSON.parse(last_response.body)
        assert_equal subscription.id, result['id']
        assert_equal subscription.feed_id, result['feed_id']
        assert_equal subscription.callback_url, result['callback_url']
      end

      should 'return not found if subscription does not exist' do
        get "/subscriptions/999999", {}, @headers
        assert_not_found
      end

      should 'return forbidden error if user is not the owner' do
        subscription = create(:subscription)
        get "/subscriptions/#{subscription.id}", {}, @headers

        assert_equal 403, last_response.status
        assert_equal 'Only the subscriber can perform this action', JSON.parse(last_response.body)['error']
      end
    end

    context 'DELETE /subscriptions/:id' do
      should 'delete a subscription if current_user is the owner' do
        subscription = create(:subscription, user: @user)
        delete "/subscriptions/#{subscription.id}", {}, @headers

        assert_equal 204, last_response.status
        assert last_response.body.empty? 
      end

      should 'forbid action if current_user is not the owner' do
        subscription = create(:subscription)
        delete "/subscriptions/#{subscription.id}", {}, @headers

        assert_equal 403, last_response.status
        assert_equal 'Only the subscriber can perform this action', JSON.parse(last_response.body)['error']  
      end

      should 'return not found if subscription does not exist' do
        delete "/subscriptions/999999", {}, @headers
        assert_not_found
      end
    end

    context 'PATCH /subscriptions/:id' do
      should 'update the callback url for a subscription if current_user is the owner' do
        subscription = create(:subscription, user: @user)
        new_callback_url = 'http://mynewcallback.com'
        patch "/subscriptions/#{subscription.id}", { callback_url: new_callback_url }, @headers

        assert_equal 200, last_response.status
        result = JSON.parse(last_response.body)

        assert_equal new_callback_url, result['callback_url']
      end

      should 'forbid action if current_user is not the owner' do
        subscription = create(:subscription)
        new_callback_url = 'http://mynewcallback.com'
        patch "/subscriptions/#{subscription.id}", { callback_url: new_callback_url }, @headers

        assert_equal 403, last_response.status
        assert_equal 'Only the subscriber can perform this action', JSON.parse(last_response.body)['error']  
      end

      should 'return error when providing invalid callback url' do
        subscription = create(:subscription, user: @user)
        new_callback_url = 'invalid.callback.com'
        patch "/subscriptions/#{subscription.id}", { callback_url: new_callback_url }, @headers

        assert_equal 400, last_response.status
        assert_equal 'Callback url is not a valid url', JSON.parse(last_response.body)['error']  
      end

      should 'return not found if subscription does not exist' do
        patch "/subscriptions/999999", { callback_url: 'http://mynewcallback.com' }, @headers
        assert_not_found
      end
    end

    context 'POST /feeds/:feed_id/messages' do
      should 'publish a message in the specified feed' do
        feed = create(:feed, user: @user)
        expected_data = { name: 'fabio', surname: 'pitino' }
        post "/feeds/#{feed.id}/messages", { data: expected_data }, @headers

        assert_equal 201, last_response.status
        response_body = JSON.parse(last_response.body)
        assert_equal expected_data.to_json, response_body['data']
        assert_equal feed.id, response_body['feed_id']
      end

      should 'enqueue notifications for subscribers when message published correctly' do
        feed = create(:feed, user: @user)
        subscription = create(:subscription, feed: feed)
        expected_data = { name: 'fabio', surname: 'pitino' }

        post "/feeds/#{feed.id}/messages", { data: expected_data }, @headers

        assert Notifier.jobs.size > 0
        assert_equal feed.subscriptions.count, Notifier.jobs.size
        Notifier.clear
      end

      should 'not allow user to publish a message to another user\'s feed' do
        feed = create(:feed, user_id: @user.id + 1)
        post "/feeds/#{feed.id}/messages", { data: { name: 'fabio' } }, @headers
        error_message = 'Only the owner of the feed is authorized to publish messages'

        assert_equal 403, last_response.status
        assert_equal error_message, JSON.parse(last_response.body)['error'] 
      end

      should 'return error if no data parameter provided' do
        feed = create(:feed, user: @user)
        post "/feeds/#{feed.id}/messages", {}, @headers

        assert_equal 400, last_response.status
        assert_equal "Missing required param 'data'", JSON.parse(last_response.body)['error']
      end

      should 'return error if no data content provided' do
        feed = create(:feed, user: @user)
        post "/feeds/#{feed.id}/messages", { data: {} }, @headers

        assert_equal 400, last_response.status
        assert_equal "Missing required param 'data'", JSON.parse(last_response.body)['error']

        post "/feeds/#{feed.id}/messages", { data: '' }, @headers

        assert_equal 400, last_response.status
        assert_equal "Data is not a valid json", JSON.parse(last_response.body)['error']
      end

      should 'return not found if feed does not exist' do
        post "/feeds/99999/message", { data: { name: 'fabio' } }, @headers
        assert_not_found
      end
    end
  end
end
