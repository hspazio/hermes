class Feed < ActiveRecord::Base
  has_many :subscriptions
  has_many :messages

  validates :name, presence: true

end