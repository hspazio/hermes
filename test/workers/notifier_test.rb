require 'test_helper'

class NotifierTest < Minitest::Test
  context 'Notifier' do
    should 'post data to callback_url' do
      data = { event: 'greetings', text: 'hello world' }.to_json
      callback_url = 'http://service/callbacks/helloworld'
      FakeWeb.register_uri(:post, callback_url, :body => 'received!')

      response = Notifier.new.perform(data, callback_url)

      assert_equal 200, response.code.to_i
      assert_equal 'received!', response.body      
    end
  end
end