class ConnectSimpleEmailWithAlumsAndUsers < ActiveRecord::Migration
  def change
    add_column :simple_emails, :user_id, :integer
    add_column :simple_emails, :alum_id, :integer
  end
end
