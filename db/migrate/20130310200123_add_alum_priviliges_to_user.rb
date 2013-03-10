class AddAlumPriviligesToUser < ActiveRecord::Migration
  def change
  	add_column :users, :alum, :boolean, default: false
  end
end
