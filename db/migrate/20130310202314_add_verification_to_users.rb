class AddVerificationToUsers < ActiveRecord::Migration
  def self.up
  	add_column :users, :verified, :boolean, :default => false
  end
end
