class CreateSimpleEmails < ActiveRecord::Migration
  def change
    create_table :simple_emails do |t|
      t.string :subject
      t.text :message

      t.timestamps
    end
  end
end
