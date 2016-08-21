class HermesClient
  class Error < StandardError; end
  
  attr_reader :host
  attr_accessor :token

  def initialize(host)
    @host = host
  end

  def login(username, password)
    response = RestClient.post host + '/login', username: username, password: password, content_type: :json, accept: :json 
    @token = JSON.parse(response)['token']
    @token
  end 

  def feeds
    request :get, "#{host}/feeds"
  end

  def feed_by_id(feed_id)
    request :get, "#{host}/feeds/#{feed_id}"
  end

  def create_feed(params)
    request :post, "#{host}/feeds", params
  end

  private

  def request(method, path, params = nil)
    headers = { content_type: :json,
	        'Authorization' => "Token token=#{token}" }
    args = [method, path, params, headers].compact
    
    begin
      response = RestClient.public_send *args
      JSON.parse(response, symbolize_names: true)
    rescue => e
      raise Error, e.inspect
    end
  end
end
