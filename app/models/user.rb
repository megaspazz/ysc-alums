class User < ActiveRecord::Base

  attr_accessible :email, :name, :alum, :password, :password_confirmation
  has_secure_password

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token

  validates(:name, presence: true, length: {maximum: 50})
  validates(:email, presence: true, uniqueness: { case_sensitive: false })
  validates(:password, presence: true, length: { minimum: 6 }, on: :create, on: :change_password)
  validates(:password_confirmation, presence: true, on: :create, on: :change_password)

  private

  	def create_remember_token
  		self.remember_token = SecureRandom.urlsafe_base64
  	end

end
