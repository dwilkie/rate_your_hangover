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

ActiveRecord::Schema.define(:version => 20110525095827) do

  create_table "hangovers", :force => true do |t|
    t.string   "title"
    t.string   "image"
    t.integer  "user_id"
    t.integer  "votes_count", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password",     :limit => 128
    t.string   "display_name"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["current_sign_in_ip"], :name => "index_users_on_current_sign_in_ip"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["last_sign_in_ip"], :name => "index_users_on_last_sign_in_ip"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "votes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "voteable_id"
    t.string   "voteable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["user_id", "voteable_id", "voteable_type"], :name => "index_votes_on_user_id_and_voteable_id_and_voteable_type", :unique => true

end
