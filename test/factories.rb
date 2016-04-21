class Minitest::Test
  include FactoryGirl::Syntax::Methods
end

FactoryGirl.define do
  to_create { |instance| instance.save }
  	
  factory :user do |f|
    f.sequence(:username) { |n| "username#{n}" }
    f.sequence(:password) { |n| "password#{n}" }
    f.password_confirmation { password }
  end

  factory :feed do |f|
    f.sequence(:name) { |n| "feed#{n}" }
  end

  factory :subscription do |f|
    f.association :feed
    f.association :user
    f.sequence(:callback_url) { |n| "http://localhost:1234/#{n}" }
  end

  factory :message do |f|
    f.association :feed
    f.association :user
    f.data ({ test: 'data' }.to_json)
  end
end