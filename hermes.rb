Bundler.require :default

class Authentication < Sinatra::Base
  enable :sessions

  post('/login') do
    if params['name'] == 'admin' && params['password'] == 'admin'
      session['user_name'] = params['name']
    else
      redirect '/login'
    end
  end
end

class Hermes < Sinatra::Base
  # use Authentication

  Dir[File.dirname(__FILE__) + '/models/**/*.rb'].each{ |f| require f }

  # TODO: move to a setup script
  # User.new(username: 'admin', password: 'Secure123!', password_confirmation: 'Secure123!').save

  # error 404 do
  #   halt 404, { error: 'Record not found' }.to_json
  # end

  helpers do
    def return_error(message, status=400)
      halt status, { error: message }.to_json
    end
  end

  enable :sessions

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

  # inded all users
  get '/users' do
    User.select(:id, :username).to_json
  end

  # index all feeds
  get '/feeds' do
    Feed.all.to_json
  end

  # create new feed
  # data >> { name: "..." }
  post '/feeds' do
    if params['name']
      feed = Feed.new({ name: params['name'] })
      feed.save
      body(feed.to_json)
      status(201)
    else
      # body({ error: 'Name must be provided' }.to_json)
      # status(400)
      return_error('Name must be provided')
    end
  end

  # show feed
  get '/feeds/:id' do |id|
    feed = Feed.find_by(id: params[:id]) || return_error('Record not found', 404)
    feed.to_json
  end

  # get '/channels/:id/subscriptions' do |id|
  #   Channel[id].subscriptions.inspect
  # end
end