class Feed < ActiveRecord::Base
  has_many :subscriptions
  has_many :messages
  belongs_to :user

  validates :name, presence: true, length: { minimum: 3 }
end