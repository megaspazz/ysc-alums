class User < ActiveRecord::Base

  include RandomStrings

  attr_accessible :email, :name, :class_year, :major, :alum, :password, :password_confirmation
  attr_accessible :title, :description
  
  attr_accessible :profile_pic
  has_attached_file :profile_pic, :styles => { :show_size => "500x640>", :search_size => "250x320" }
  
  attr_accessible :country, :state, :city
  geocoded_by :location
  before_save :check_for_geocode

  has_many :topics
  attr_accessible :other_topic
  
  searchable do
    text :name, :major, :class_year, :title, :description, :city, :state, :country
  end

  # Alum emails are the ones received by the user (presumably an alum)
  # Remember that the database column is :alum_id, NOT :alum
  has_many :alum_emails, :class_name => 'SimpleEmail', :foreign_key => :alum_id

  # User emails are the ones sent by the user (presumably a student)
  # Remember that the database column is :user_id, NOT :user
  has_many :user_emails, :class_name => 'SimpleEmail', :foreign_key => :user_id

  has_secure_password

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token
  before_save :clean_other_topic

  attr_accessor :should_validate_name, :should_validate_email, :should_validate_password

  validates(:name, :presence => true, :length => {:maximum => 50}, :if => :val_name)
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates(:email, :presence => true, :uniqueness => { :case_sensitive => false }, :format => { :with => VALID_EMAIL_REGEX }, :if => :val_email)
  validates(:password, :presence => true, :length => { :minimum => 6 }, :if => :val_password)
  validates(:password_confirmation, :presence => true, :if => :val_password)
  
  # Removes undesired error messages.
  def filtered_error_messages
    filtered_errors = self.errors.clone
    # Delete the :password_digest message because it's repeated (password_digest is used by the magical authentication system in the database
    filtered_errors.delete(:password_digest)
    # Delete the :email error message if it contains "blank" since we don't want that particular error message... this is slightly hard coded so updates to Ruby / Rails may or may not break this code! 
    filtered_errors.messages[:email].delete_if { |m| m.include?("blank") } if errors.messages[:email].present?
    # Return the new list of errors
    filtered_errors
  end
  
  # Returns a nice-looking string for their location in the form [city][, ][state][, ][country]
  def display_location
    loc = ""
    if !self.city.blank?
      loc += self.city
      if (!self.state.blank? || !self.country.blank?)
        loc += ", "
      end
    end
    if !self.state.blank?
      loc += self.state
      if (!self.country.blank?)
        loc += ", "
      end
    end
    if (!self.country.blank?)
      loc += self.country
    end
    loc
  end
  
  # Used for displaying general info.  Will start with a comma,  if either a major or class_year is present.
  def display_general_info
    gen_info = ""
    if (!self.major.blank? || !self.class_year.blank?)
      gen_info += ", "
    end
    if (!self.major.blank?)
      gen_info += self.major
      if (!self.class_year.blank?)
        gen_info += ", "
      end
    end
    if (!self.class_year.blank?)
      gen_info += self.class_year
    end
    gen_info
  end
  
  def get_display_image(image_type, class_type)
    image_tag(self.profile_pic.url(image_type), :class => class_type) unless self.profile_pic.nil?
  end

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

    # This makes sure the other_topic isn't blank, and if it has only spaces, make it blank
    def clean_other_topic
      self.other_topic = "" if self.other_topic.blank?
    end
    
    # City is required for searching by GPS coordinates
    def check_for_geocode
      geocode if ((self.city_changed? || self.state_changed? || self.country_changed?) && !self.city.blank?)
    end
    
end
