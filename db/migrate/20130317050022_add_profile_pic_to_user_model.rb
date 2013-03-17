class AddProfilePicToUserModel < ActiveRecord::Migration
  def change
    add_column :users, :profile_pic_file_name, :string
    add_column :users, :profile_pic_content_type, :string
    add_column :users, :profile_pic_file_size, :integer
    add_column :users, :profile_pic_updated_at, :datetime
  end
end
