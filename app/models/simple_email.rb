class SimpleEmail < ActiveRecord::Base

  attr_accessible :message, :subject

  belongs_to :alum, :class_name => 'User'    # its :foreign_key in the database is :alum_id
  belongs_to :user, :class_name => 'User'    # its :foreign_key in the database is :user_id

  validates(:message, :presence => true)
  validates(:subject, :presence => true)
  
  def self.admin_cp_methods
    list = SimpleEmail.accessible_attributes.to_a
    list.delete("")
    list.insert(0, :to_email)
    list.insert(0, :to)
    list.insert(0, :from_email)
    list.insert(0, :from)
    list.push("created_at")
    # Possibly add other things of interest
    list
  end
  
  def from
    self.user.name
  end
  
  def from_email
    self.user.email
  end
  
  def to
    self.alum.name
  end
  
  def to_email
    self.alum.email
  end
  
end
