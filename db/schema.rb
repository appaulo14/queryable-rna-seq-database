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

ActiveRecord::Schema.define(:version => 13) do

  create_table "datasets", :force => true do |t|
    t.string   "name",                    :null => false
    t.boolean  "has_transcript_diff_exp", :null => false
    t.boolean  "has_transcript_isoforms", :null => false
    t.boolean  "has_gene_diff_exp",       :null => false
    t.string   "blast_db_location",       :null => false
    t.integer  "user_id",                 :null => false
    t.datetime "when_last_queried"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "differential_expression_tests", :force => true do |t|
    t.integer "fpkm_sample_1_id", :limit => 8, :null => false
    t.integer "fpkm_sample_2_id", :limit => 8, :null => false
    t.integer "gene_id",          :limit => 8
    t.integer "transcript_id",    :limit => 8
    t.string  "test_status",                   :null => false
    t.decimal "log_fold_change",               :null => false
    t.decimal "p_value",                       :null => false
    t.decimal "fdr",                           :null => false
  end

  create_table "fpkm_samples", :force => true do |t|
    t.integer "gene_id",       :limit => 8
    t.integer "transcript_id", :limit => 8
    t.integer "sample_id",     :limit => 8, :null => false
    t.decimal "fpkm",                       :null => false
    t.decimal "fpkm_hi"
    t.decimal "fpkm_lo"
    t.string  "status"
  end

  create_table "genes", :force => true do |t|
    t.integer "dataset_id",        :limit => 8, :null => false
    t.string  "name_from_program",              :null => false
  end

  create_table "go_terms", :id => false, :force => true do |t|
    t.string "id",   :null => false
    t.string "term", :null => false
  end

  create_table "sample_comparisons", :id => false, :force => true do |t|
    t.integer "sample_1_id", :null => false
    t.integer "sample_2_id", :null => false
  end

  create_table "samples", :force => true do |t|
    t.string  "name"
    t.integer "dataset_id", :null => false
  end

  create_table "transcript_fpkm_tracking_informations", :id => false, :force => true do |t|
    t.integer "transcript_id", :limit => 8, :null => false
    t.string  "class_code",                 :null => false
    t.integer "length",                     :null => false
    t.decimal "coverage"
  end

  create_table "transcript_has_go_terms", :id => false, :force => true do |t|
    t.integer "transcript_id", :null => false
    t.string  "go_term_id",    :null => false
  end

  create_table "transcripts", :force => true do |t|
    t.integer "dataset_id",        :limit => 8, :null => false
    t.integer "gene_id",           :limit => 8
    t.string  "name_from_program",              :null => false
    t.string  "blast_seq_id",                   :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "name",                                   :null => false
    t.text     "description"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.boolean  "admin"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
