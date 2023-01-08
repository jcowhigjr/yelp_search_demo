# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_01_08_185633) do
  create_table "coffeeshops", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.float "rating"
    t.string "yelp_url"
    t.string "image_url"
    t.string "phone_number", default: "None"
    t.integer "search_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["search_id"], name: "index_coffeeshops_on_search_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.string "content"
    t.float "rating"
    t.integer "user_id"
    t.integer "coffeeshop_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coffeeshop_id"], name: "index_reviews_on_coffeeshop_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "searches", force: :cascade do |t|
    t.integer "user_id"
    t.string "query"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "latitude", precision: 16, scale: 6
    t.decimal "longitude", precision: 16, scale: 6
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "user_favorites", force: :cascade do |t|
    t.integer "user_id"
    t.integer "coffeeshop_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coffeeshop_id"], name: "index_user_favorites_on_coffeeshop_id"
    t.index ["user_id"], name: "index_user_favorites_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name", unique: true
  end

end
