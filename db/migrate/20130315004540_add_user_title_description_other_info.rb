class AddUserTitleDescriptionOtherInfo < ActiveRecord::Migration
  def change
	  add_column :users, :title, :string
	  add_column :users, :description, :text
	  add_column :users, :other_topic, :string
  end
end
