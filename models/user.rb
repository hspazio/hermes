class User < ActiveRecord::Base
  has_secure_password

  validates :username, presence: true, uniqueness: true, length: { minimum: 3 }
end