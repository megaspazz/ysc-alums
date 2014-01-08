class User < ActiveRecord::Base

  # Kind of a pain that we have to include this, since it's not a global class...
  include RandomStrings

  # Perhaps default values for the string fields should be an empty string instead of nil to make it nicer to search
  # Right now, the search checks to make sure that the field isn't blank before searching it

  attr_accessible :email, :name, :residential_college, :class_year, :major, :alum, :password, :password_confirmation
  attr_accessible :title, :description
  attr_accessible :last_visited
  
  attr_accessible :profile_pic
  has_attached_file :profile_pic, :styles => { :show_size => "500x640>", :search_size => "250x320>" }
  
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
  before_save :clean_other_topic

  attr_accessor :should_validate_name, :should_validate_email, :should_validate_password

  validates(:name, :presence => true, :length => {:maximum => 50}, :if => :val_name)
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates(:email, :presence => true, :uniqueness => { :case_sensitive => false }, :format => { :with => VALID_EMAIL_REGEX }, :if => :val_email)
  validates(:password, :presence => true, :length => { :minimum => 6 }, :if => :val_password)
  validates(:password_confirmation, :presence => true, :if => :val_password)
  
  # A class-static hash used to convert the residential college into its abbreviation from a symbol containing the college's name
  # See app/controllers/users_controller.rb for a similar hash
  @@res_col_abbrev = ActiveSupport::OrderedHash.new
  @@res_col_abbrev[:default_none] = ""
  @@res_col_abbrev[:pierson] = "PC"
  @@res_col_abbrev[:davenport] = "DC"
  @@res_col_abbrev[:ezra_stiles] = "ES"
  @@res_col_abbrev[:morse] = "MC"
  @@res_col_abbrev[:saybrook] = "SY"
  @@res_col_abbrev[:trumbull] = "TC"
  @@res_col_abbrev[:berkeley] = "BK"
  @@res_col_abbrev[:silliman] = "SM"
  @@res_col_abbrev[:timothy_dwight] = "TD"
  @@res_col_abbrev[:branford] = "BR"
  @@res_col_abbrev[:calhoun] = "CC"
  @@res_col_abbrev[:jonathan_edwards] = "JE"
  
  def residential_college_abbreviation
    @@res_col_abbrev[self.residential_college.to_sym] unless (self.residential_college.blank?)
  end
  
  # Assumes that the :class_year was given as four-characters
  def class_year_abbreviation
    "'" + self.class_year[2..4] unless (self.class_year.blank?)
  end

  def college_and_year_abbreviation
    cy_str = ""
    if (!residential_college_abbreviation.blank?)
        cy_str += residential_college_abbreviation
        if (!class_year_abbreviation.blank?)
            cy_str += " "
        end
    end
    if (!class_year_abbreviation.blank?)
        cy_str += class_year_abbreviation
    end
    cy_str
  end
  
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
  
  def display_general_info
    gen_info = ""
    if (!self.major.blank?)
        gen_info += self.major
        if (!college_and_year_abbreviation.blank?)
            gen_info += ", "
        end
    end
    if (!college_and_year_abbreviation.blank?)
        gen_info += college_and_year_abbreviation
    end
    gen_info
  end
  
  # Used for displaying college info.  Will start with a comma,  if either a major or class_year is present.
  def display_college_info
    gen_info = ""
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
  
  # THIS METHOD IS UNUSED!  SHOULD PROBABLY DELETE SOMETIME!!!
  def get_display_image(image_type, class_type)
    image_tag(self.profile_pic.url(image_type), :class => class_type) unless self.profile_pic.nil?
  end
    
  # The following class-static hash is used to weight the searches based on the field
  @@search_weights = { :name => 10,
                       :email => 8,
                       :class_year => 11,
                       :major => 10,
                       :title => 6,
                       :description => 2,
                       :city => 9,
                       :state => 11,
                       :country => 13,
                       :other_topic => 14,
                       :residential_college => 9,
                       :residential_college_abbreviation => 5,
                       :class_year_abbreviation => 8
                       }

  # Include a blacklist of words not to search?  i.e. 'a', 'the', etc.  It probably would be a nice feature
  @@search_blacklist = ('a'..'z').to_a + ["on", "in", "an", "the", "of"]
  
  # Assigns a simple score based on the weights and whether or not (NOT number of times) each word appears in a field
  # Could probably make this method more useful by allowing the removal of unique or blacklist or match case, etc.         
  def search_score(search_string)
    # No punctuation, as that would mess up the search OR create a method to strip punctuation
    # Split the search string into words (by spaces)
    string_array = search_string.split(' ')
    # Only take unique words (will probably have a problem with plurals)
    string_array.uniq!
    # Make everything downcase for easier searching
    string_array = string_array.map { |str| str.downcase }
    # Remove words from the blacklist
    @@search_blacklist.each do |str| string_array.delete(str) end
    score = 0
    string_array.each do |str|
      @@search_weights.each_pair do |k, v|
        find_str = self.send(k)
        if !find_str.blank? && find_str.downcase.include?(str.downcase)
          score += @@search_weights[k]
        end
      end
    end
    # Return the final score
    score
  end

  # Returns the user's profile picture, or returns the default picture (default_profile_pic.png is a seedling right now)
  # This method needs to get the image_tag from a different class -- probably not the best style?
  # image_type should be a symbol
  def profile_pic_image_tag(image_type, class_type)
    if (self.profile_pic.present?)
      ActionController::Base.helpers.image_tag(self.profile_pic.url(image_type), :class => class_type)
    else
      ActionController::Base.helpers.image_tag('default_profile_pic.png', :alt => 'missing', :class => class_type)
    end
  end
  
  # Returns the user's name, with only the last name initialized.
  def abbreviated_name
    i = self.name.index(/[\s][a-zA-Z]+$/)
    if (i.nil?)
      self.name
    else
      self.name[0..i+1] + "."
    end
  end
  
  def sent_emails
    SimpleEmail.find(:all, :conditions => { :user_id => self.id })
  end
  
  def sent_emails_count
    sent_emails.count
  end
  
  def received_emails
    SimpleEmail.find(:all, :conditions => { :alum_id => self.id })
  end
  
  def received_emails_count
    received_emails.count
  end
  
  # This returns an array of strings
  # Note the differences with self.admin_cp_methods
  def self.admin_cp_attributes
    list = User.new.attributes.keys
    #list.delete("")
    #list.delete("password")
    #list.delete("password_confirmation")
    #list.push("admin")
    # Possibly add number of emails sent
    list
  end
  
  # This returns an array of symbols
  # Note the differences with self.admin_cp_attributes
  def self.admin_cp_methods
    [:sent_emails_count, :received_emails_count]
  end

  private

  	def create_remember_token
  		self.remember_token = urlsafe_randstr
  	end

    def val_name
      should_validate_name || self.new_record?    # new record = created but not saved
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
