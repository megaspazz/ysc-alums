class AddConfirmationCodeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :confirmation_code, :string
  end
end
