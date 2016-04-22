Bundler.require :default
Dir[File.dirname(__FILE__) + '/models/**/*.rb'].each{ |f| require f }

class Hermes < Sinatra::Base
  configure do
    enable :sessions
  end

  helpers do
    def current_user
      User.find(session['user_id'])
    end

    def authenticate!
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
    authenticate! unless request.path_info == '/login'
  end

  post '/login' do
    if params['username'] && params['password']
      user = User.where(username: params['username']).first
      if user
        if user.authenticate(params['password'])
          session['user_id'] = user.id
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
      
    feed = Feed.new({ name: params['name'] })
    if feed.save
      body feed.to_json
      status 201 
    else
      return_error(feed.errors.full_messages.join("\n"))
    end
  end

  # show feed
  get '/feeds/:id' do 
    feed = Feed.find_by(id: params[:id]) || return_not_found
    feed.to_json
  end

  # show all subscriptions to a feed
  get '/feeds/:feed_id/subscriptions' do
    feed = Feed.find_by(id: params[:feed_id]) || return_not_found
    feed.subscriptions.to_json
  end

  # subscribe to a feed
  post '/feeds/:feed_id/subscriptions' do
    feed = Feed.find_by(id: params[:feed_id]) || return_not_found
    subscription = feed.subscriptions.build(user: current_user, callback_url: params[:callback_url])

    if subscription.save
      body(subscription.to_json)
      status 201
    else
      return_error(subscription.errors.full_messages.to_sentence)
    end
  end

  # show subscription
  get '/subscriptions/:id' do
    subscription = Subscription.find_by(id: params[:id]) || return_not_found
    subscription.to_json
  end

  # unsubscribe from a feed
  delete '/subscriptions/:id' do
    subscription = Subscription.find_by(id: params[:id]) || return_not_found
    if subscription.user == current_user
      if subscription.destroy
        status 204
      else
        return_error('Unable to complete request', 500)
      end
    else
      return_error('Only the subscriber can perform this action', 403)
    end
  end

end