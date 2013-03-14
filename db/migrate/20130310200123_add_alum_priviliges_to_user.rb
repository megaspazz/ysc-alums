class AddAlumPriviligesToUser < ActiveRecord::Migration
  def self.up
  	add_column :users, :alum, :boolean, :default => false
  end
end
