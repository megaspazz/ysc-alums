class User < ActiveRecord::Base

  include RandomStrings

  attr_accessible :email, :name, :class_year, :major, :alum, :password, :password_confirmation
  attr_accessible :title, :description

  attr_accessible :country, :state, :city
  geocoded_by :location
  before_save :check_for_geocode

  has_many :topics
  attr_accessible :other_topic

  # Alum emails are the ones received by the user (presumably an alum)
  # Remember that the database column is :alum_id, NOT :alum
  has_many :alum_emails, :class_name => 'SimpleEmail', :foreign_key => :alum_id

  # User emails are the ones sent by the user (presumably a student)
  # Remember that the database column is :user_id, NOT :user
  has_many :user_emails, :class_name => 'SimpleEmail', :foreign_key => :user_id

  has_secure_password

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token

  attr_accessor :should_validate_name, :should_validate_email, :should_validate_password

  validates(:name, :presence => true, :length => {:maximum => 50}, :if => :val_name)
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates(:email, :presence => true, :uniqueness => { :case_sensitive => false }, :format => { :with => VALID_EMAIL_REGEX }, :if => :val_email)
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

    def location
      "#{self.city}, #{self.state}, #{self.country}"
    end
    
    # City is required for searching by GPS coordinates
    def check_for_geocode
      geocode if ((self.city_changed? || self.state_changed? || self.country_changed?) && !self.city.blank?)
    end
    
end
