# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130521031346) do

  create_table "simple_emails", :force => true do |t|
    t.string   "subject"
    t.text     "message"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
    t.integer  "alum_id"
    t.string   "user_name"
    t.string   "user_email"
    t.string   "alum_name"
    t.string   "alum_email"
  end

  create_table "topics", :force => true do |t|
    t.string   "content"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.string   "password"
    t.string   "password_confirmation"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",                    :default => false
    t.boolean  "alum",                     :default => false
    t.boolean  "verified",                 :default => false
    t.string   "country"
    t.string   "state"
    t.string   "city"
    t.string   "confirmation_code"
    t.string   "title"
    t.text     "description"
    t.string   "other_topic"
    t.string   "class_year"
    t.string   "major"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "profile_pic_file_name"
    t.string   "profile_pic_content_type"
    t.integer  "profile_pic_file_size"
    t.datetime "profile_pic_updated_at"
    t.string   "residential_college"
    t.datetime "last_visited"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
