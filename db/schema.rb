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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150221224519) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "course_professor_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "course_professor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_professors", force: true do |t|
    t.integer  "professor_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses", force: true do |t|
    t.string   "name",       limit: 50
    t.string   "key",        limit: 8
    t.integer  "semester"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_users", force: true do |t|
    t.integer  "status"
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: true do |t|
    t.string   "name",         null: false
    t.integer  "owner_id",     null: false
    t.integer  "member_count", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "professors", force: true do |t|
    t.string   "name"
    t.string   "last_names"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scores", force: true do |t|
    t.integer  "innovation_score"
    t.integer  "creativity_score"
    t.integer  "functionality_score"
    t.integer  "business_model_score"
    t.integer  "modeling_tools_score"
    t.string   "observations",         limit: 512
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tokens", force: true do |t|
    t.string   "token"
    t.string   "secret"
    t.datetime "expires_at"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name",            limit: 50,  null: false
    t.string   "last_names",      limit: 60,  null: false
    t.string   "enrollment",      limit: 9,   null: false
    t.integer  "major",                       null: false
    t.integer  "campus",                      null: false
    t.string   "hashed_password", limit: 128, null: false
    t.integer  "identity",                    null: false
    t.boolean  "active",                      null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_foreign_key "course_professor_users", "course_professors", name: "course_professor_users_course_professor_id_fk"
  add_foreign_key "course_professor_users", "users", name: "course_professor_users_user_id_fk"

  add_foreign_key "course_professors", "courses", name: "course_professors_course_id_fk"
  add_foreign_key "course_professors", "professors", name: "course_professors_professor_id_fk"

  add_foreign_key "groups", "users", name: "groups_owner_id_fk", column: "owner_id"

  add_foreign_key "scores", "users", name: "scores_user_id_fk"

end
