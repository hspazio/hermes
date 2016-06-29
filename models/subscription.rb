require 'uri'

class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
  	unless value =~ /\A#{URI::regexp(['http', 'https'])}\z/
      record.errors[attribute] << (options[:message] || "is not a valid url")
    end
  end
end

class Subscription < ActiveRecord::Base
  belongs_to :feed
  belongs_to :user

  validates :feed, presence: true
  validates :user, presence: true, uniqueness: { scope: :feed, 
  	               message: "is already a subscriber of the feed" }
  validates :callback_url, presence: true
  validates :callback_url, url: true, if: ->{ callback_url.present? }
end