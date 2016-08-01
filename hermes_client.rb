class HermesClient
  attr_reader :host

  def initialize(host)
    @host = host
  end

  def login(username, password)
    RestClient.post host + '/login', username: username, password: password, content_type: :json, accept: :json 
  end 
end