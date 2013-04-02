class AddResidentialCollegeToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :residential_college, :string
  end
end
