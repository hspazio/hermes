class User < ActiveRecord::Base
  has_secure_password
  has_many :feeds

  validates :username, presence: true, uniqueness: true, length: { minimum: 3 }
end