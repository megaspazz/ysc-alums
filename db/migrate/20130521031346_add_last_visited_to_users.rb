class AddLastVisitedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_visited, :datetime
  end
end
