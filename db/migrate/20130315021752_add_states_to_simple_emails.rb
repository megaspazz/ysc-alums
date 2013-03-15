class AddStatesToSimpleEmails < ActiveRecord::Migration
  def change
    add_column :simple_emails, :user_name, :string
    add_column :simple_emails, :user_email, :string
    add_column :simple_emails, :alum_name, :string
    add_column :simple_emails, :alum_email, :string
  end
end
