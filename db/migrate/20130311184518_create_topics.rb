class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :content
      t.integer :user_id

      t.timestamps
    end
  end
end
