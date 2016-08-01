class User < ActiveRecord::Base
  has_secure_password
  has_many :feeds

  validates :username, presence: true, uniqueness: true, length: { minimum: 3 }

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def generate_token
    update(token: SecureRandom.hex(16))
  end
end