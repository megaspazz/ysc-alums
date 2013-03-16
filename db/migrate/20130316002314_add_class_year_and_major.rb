class AddClassYearAndMajor < ActiveRecord::Migration
  def change
	  add_column :users, :class_year, :string
	  add_column :users, :major, :string
  end
end
