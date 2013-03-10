class InitialFixOfUsers < ActiveRecord::Migration
  def change
	add_index :users, :email, unique: true
	add_column :users, :password_digest, :string
	add_column(:users, :remember_token, :string)
  	add_index(:users, :remember_token)
  	add_column :users, :admin, :boolean, default: false
  end
end
