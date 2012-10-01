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

ActiveRecord::Schema.define(:version => 20121001200119) do

  create_table "job_statuses", :id => false, :force => true do |t|
    t.string   "name",        :null => false
    t.string   "description", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "jobs", :force => true do |t|
    t.string   "job_status",             :null => false
    t.string   "current_program",        :null => false
    t.string   "current_program_status", :null => false
    t.string   "eid_of_owner",           :null => false
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "program_statuses", :id => false, :force => true do |t|
    t.string   "name",        :null => false
    t.string   "description", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "programs", :id => false, :force => true do |t|
    t.string   "name",        :null => false
    t.string   "description", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users", :id => false, :force => true do |t|
    t.string   "eid",        :null => false
    t.string   "email",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_foreign_key "jobs", "job_statuses", :name => "job_statuses_fk", :column => "job_status", :primary_key => "name", :dependent => :restrict
  add_foreign_key "jobs", "program_statuses", :name => "program_statuses_fk", :column => "current_program_status", :primary_key => "name", :dependent => :restrict
  add_foreign_key "jobs", "programs", :name => "programs_fk", :column => "current_program", :primary_key => "name", :dependent => :restrict
  add_foreign_key "jobs", "users", :name => "users_fk", :column => "eid_of_owner", :primary_key => "eid", :dependent => :restrict

end
