class User < ActiveRecord::Base

  include RandomStrings

  attr_accessible :email, :name, :alum, :password, :password_confirmation
  attr_accessible :country, :state, :city
  has_many :topics

  has_secure_password

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token

  attr_accessor :should_validate_name, :should_validate_email, :should_validate_password

  validates(:name, :presence => true, :length => {:maximum => 50}, :if => :val_name)
  VALID_YALE_EMAIL_REGEX = /\A[\w+\-.]+@(aya\.)?yale\.edu\z/i

  validates(:email, :presence => true, :uniqueness => { :case_sensitive => false }, :format => { :with => VALID_YALE_EMAIL_REGEX }, :if => :val_email)
  validates(:password, :presence => true, :length => { :minimum => 6 }, :if => :val_password)
  validates(:password_confirmation, :presence => true, :if => :val_password)

  private

  	def create_remember_token
  		self.remember_token = urlsafe_randstr # @string
  	end

    def val_name
      should_validate_name || self.new_record?  # new record = created but not saved
    end

    def val_email
      should_validate_email || self.new_record?
    end

    def val_password
      should_validate_password || self.new_record?
    end
end
