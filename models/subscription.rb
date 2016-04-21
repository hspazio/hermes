class Subscription < ActiveRecord::Base
  belongs_to :feed
  belongs_to :user

  validates_presence_of :user
  validates_presence_of :feed
  # TODO: use a proper url validation
  # validates :callback_url
end