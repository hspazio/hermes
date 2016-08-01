class Notifier
  include Sidekiq::Worker

  def perform(data, callback_url)
    url = URI.parse(callback_url)
    Net::HTTP.post_form(url, JSON.parse(data))
  end
end