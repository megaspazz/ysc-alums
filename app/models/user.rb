class User < ActiveRecord::Base

  attr_accessible :email, :name, :alum, :password, :password_confirmation
  attr_accessor :should_validate_name, :should_validate_email, :should_validate_password
  has_secure_password

  has_many :topics

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token

  validates(:name, presence: true, length: {maximum: 50}, if: :val_name)
  validates(:email, presence: true, uniqueness: { case_sensitive: false }, if: :val_email)
  validates(:password, presence: true, length: { minimum: 6 }, if: :val_password)
  validates(:password_confirmation, presence: true, if: :val_password)

  private

  	def create_remember_token
  		self.remember_token = SecureRandom.urlsafe_base64
  	end

    def val_name
      should_validate_name || new_record?
    end

    def val_email
      should_validate_email || new_record?
    end

    def val_password
      should_validate_password || new_record?
    end
end
