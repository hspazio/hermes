class JsonValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    JSON.parse(value)
    true
  rescue
    record.errors[attribute] << (options[:message] || "is not a valid json")
  end
end

class Message < ActiveRecord::Base
  belongs_to :feed
  belongs_to :user    # TODO: delete

  validates_presence_of :feed
  validates :data, presence: true, json: true
end