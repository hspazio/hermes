require File.expand_path '../test_helper.rb', __FILE__

class HermesTest < MiniTest::Test
  include Rack::Test::Methods
  include TestHelper

  def app
    Hermes
  end

  context 'POST /login' do
    should 'authenticate with correct username and password' do
      user = create(:user)
      post '/login', username: user.username, password: user.password

      assert_equal 201, last_response.status 
      assert_equal '', last_response.body
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
    setup do
      10.times { create(:user) }
    end
   
    should 'list all users' do
      get '/users'

      assert_equal 200, last_response.status
      JSON.parse(last_response.body).each do |user|
        assert_match(/^user/, user['username'])
        assert_operator 0, :<, user['id']
        assert !user['password'].present?
        assert !user['password_digest'].present?
      end 
    end
  end

  context 'GET /feeds' do
  	should 'list available feeds' do
  	  create(:feed)	
      get '/feeds'

      assert last_response.ok?
      JSON.parse(last_response.body).each do |feed|
        assert_match(/feed/, feed['name'])
        assert !feed['created_at'].nil?
      end
  	end
  end

  context 'GET /feeds/:id' do
  	should 'show a valid feed by id' do
  	  feed = create(:feed)
      get "/feeds/#{feed.id}"

      assert last_response.ok?
      assert_equal feed.id, JSON.parse(last_response.body)['id']
  	end

  	should 'return not_found for invalid feed id' do
      get '/feeds/999999'
      assert_equal 404, last_response.status
      assert_equal 'Record not found', JSON.parse(last_response.body)['error']
  	end
  end

  context 'POST /feeds' do
    should 'create a new feed' do
      post '/feeds', { name: 'test_feed' }

      assert_equal 201, last_response.status
      result = JSON.parse(last_response.body)
      assert_equal 'test_feed', result['name']
      assert result['id'].present?
      assert result['created_at'].present?
      assert result['updated_at'].present?
    end
  end
end