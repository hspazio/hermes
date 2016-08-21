require 'bundler'
Bundler.require :default
Dir[File.dirname(__FILE__) + '/models/**/*.rb'].each{ |f| require f }
Dir[File.dirname(__FILE__) + '/workers/**/*.rb'].each{ |f| require f }

class Hermes < Sinatra::Base
  configure do
    enable :sessions
    mime_type :json, 'application/json'
  end

  configure :production, :development do
    enable :logging
  end

  helpers do
    def current_user
      User.find(session['user_id'])
    end

    def authenticate!
      authorization = env['Authorization'] || env['HTTP_AUTHORIZATION']
      if authorization && authorization.match(/Token token=(.*)/)
        if (user = User.find_by(token: $1))
          session['user_id'] = user.id
        end 
      end
      return_error('Unauthorized access. Please login', 401) unless session['user_id']
    end

    def return_error(message, status=400)
      halt status, { error: message }.to_json
    end

    def return_not_found
      return_error('Record not found', 404)
    end
  end

  before do
    authenticate! unless ['/', '/login'].include?(request.path_info)
    content_type :json
  end

  before '/feeds/:feed_id*' do
    @feed = Feed.find_by(id: params[:feed_id]) || return_not_found
  end

  before '/subscriptions/:id*' do
    @subscription = Subscription.find_by(id: params[:id]) || return_not_found
 
    unless @subscription.user == current_user
      return_error('Only the subscriber can perform this action', 403)
    end
  end

  after '/feeds/:feed_id/messages' do
    if request.post? && @feed && @message && @message.valid?
      @feed.subscriptions.each do |subscription|
        Notifier.perform_async(@message.data, subscription.callback_url)
      end
    end
  end

  get '/' do
    "Hermes"
  end

  post '/login' do
    if params['username'] && params['password']
      user = User.where(username: params['username']).first
      if user
        if user.authenticate(params['password'])
          # session['user_id'] = user.id
          user.generate_token
          body({ token: user.token }.to_json)
          status 201
        else
          return_error('Invalid username and password combination', 422)
        end
      else
        return_error("User '#{params['username']}' not found", 404)  
      end
    else
      return_error('Missed required params username and password', 400)  
    end
  end

  # index all users
  get '/users' do
    User.select(:id, :username).to_json
  end

  get '/users/:id' do
    user = User.select(:id, :username).find_by(id: params[:id]) || return_not_found
    user.to_json
  end

  # index all feeds
  get '/feeds' do
    Feed.all.to_json
  end

  # create new feed
  # data >> { name: "..." }
  post '/feeds' do
    return_error('Parameter \'name\' must be provided') unless params['name']
      
    feed = Feed.new({ name: params['name'], user: current_user })
    if feed.save
      body feed.to_json
      status 201 
    else
      return_error(feed.errors.full_messages.join("\n"))
    end
  end

  # show feed
  get '/feeds/:feed_id' do 
    @feed.to_json
  end

  # show all subscriptions to a feed
  get '/feeds/:feed_id/subscriptions' do
    @feed.subscriptions.to_json
  end

  # subscribe to a feed
  post '/feeds/:feed_id/subscriptions' do
    subscription = @feed.subscriptions.build(user: current_user, callback_url: params[:callback_url])

    if subscription.save
      body(subscription.to_json)
      status 201
    else
      return_error(subscription.errors.full_messages.to_sentence)
    end
  end

  # show subscription
  get '/subscriptions/:id' do
    @subscription.to_json
  end

  # unsubscribe from a feed
  delete '/subscriptions/:id' do
    if @subscription.destroy
      status 204
    else
      return_error('Unable to complete request', 500)
    end
  end

  # update callback url
  patch '/subscriptions/:id' do
    if @subscription.update(callback_url: params[:callback_url])
      body(@subscription.to_json)
      status 200
    else
      return_error(@subscription.errors.full_messages.to_sentence)
    end
  end

  # publish message
  post '/feeds/:feed_id/messages' do
    return_error('Only the owner of the feed is authorized to publish messages', 403) unless @feed.user == current_user
    return_error("Missing required param 'data'", 400) unless params[:data]

    @message = @feed.messages.build(data: params[:data].to_json)
    if @message.save
      body @message.to_json
      status 201 
    else
      return_error(@message.errors.full_messages.to_sentence)
    end
  end
end
