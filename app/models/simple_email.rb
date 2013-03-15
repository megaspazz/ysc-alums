class SimpleEmail < ActiveRecord::Base
  attr_accessible :message, :subject

  belongs_to :alum, :class_name => 'User'    # its :foreign_key in the database is :alum_id
  belongs_to :user, :class_name => 'User'    # its :foreign_key in the database is :user_id

  validates(:message, :presence => true)
  validates(:subject, :presence => true)
end
