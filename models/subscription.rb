class Subscription < ActiveRecord::Base
  belongs_to :feed
  belongs_to :user

  validates_presence_of :user
  validates_presence_of :feed
  validates :callback_url, presence: true # TODO: use a proper url validation
end