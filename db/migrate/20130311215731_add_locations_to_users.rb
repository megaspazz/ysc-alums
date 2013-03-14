class AddLocationsToUsers < ActiveRecord::Migration
  def self.up
	  add_column :users, :country, :string
	  add_column :users, :state, :string
	  add_column :users, :city, :string
  end
end
