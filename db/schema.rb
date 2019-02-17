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

ActiveRecord::Schema.define(version: 2018_11_04_203952) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "achievement_dependencies", force: :cascade do |t|
    t.bigint "achievement_id"
    t.integer "dependency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_id"], name: "index_achievement_dependencies_on_achievement_id"
  end

  create_table "achievements", force: :cascade do |t|
    t.string "name"
    t.string "short_description"
    t.text "full_description"
    t.integer "base_points"
    t.date "expires"
    t.boolean "has_parents"
    t.boolean "is_multiplayer"
    t.boolean "is_global"
    t.boolean "is_suggested_global"
    t.bigint "user_id"
    t.integer "kind"
    t.integer "icon"
    t.bigint "category_id"
    t.integer "mode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hash_identifier"
    t.integer "upvotes"
    t.integer "downvotes"
    t.index "to_tsvector('english'::regconfig, (name)::text)", name: "index_achievements_on_name", using: :gin
    t.index "to_tsvector('english'::regconfig, (short_description)::text)", name: "index_achievements_on_short_description", using: :gin
    t.index "to_tsvector('english'::regconfig, full_description)", name: "index_achievements_on_full_description", using: :gin
    t.index ["category_id"], name: "index_achievements_on_category_id"
    t.index ["icon"], name: "index_achievements_on_icon"
    t.index ["kind"], name: "index_achievements_on_kind"
    t.index ["mode"], name: "index_achievements_on_mode"
    t.index ["user_id"], name: "index_achievements_on_user_id"
  end

  create_table "achievements_objectives", id: false, force: :cascade do |t|
    t.bigint "objective_id"
    t.bigint "achievement_id"
    t.index ["achievement_id"], name: "index_achievements_objectives_on_achievement_id"
    t.index ["objective_id"], name: "index_achievements_objectives_on_objective_id"
  end

  create_table "categories", force: :cascade do |t|
    t.integer "category_id"
    t.text "description"
    t.integer "icon"
    t.integer "points"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["icon"], name: "index_categories_on_icon"
    t.index ["title"], name: "index_categories_on_title", unique: true
  end

  create_table "continents", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "coop_requests", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "target_id"
    t.bigint "achievement_id"
    t.bigint "list_id"
    t.boolean "pending"
    t.boolean "complete"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "message"
    t.index ["achievement_id"], name: "index_coop_requests_on_achievement_id"
    t.index ["list_id"], name: "index_coop_requests_on_list_id"
    t.index ["target_id"], name: "index_coop_requests_on_target_id"
    t.index ["user_id"], name: "index_coop_requests_on_user_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.bigint "region_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["region_id"], name: "index_countries_on_region_id"
  end

  create_table "followed_lists", force: :cascade do |t|
    t.bigint "list_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id"], name: "index_followed_lists_on_list_id"
    t.index ["user_id"], name: "index_followed_lists_on_user_id"
  end

  create_table "friend_requests", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "to_id"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["to_id"], name: "index_friend_requests_on_to_id"
    t.index ["user_id"], name: "index_friend_requests_on_user_id"
  end

  create_table "friends", id: false, force: :cascade do |t|
    t.integer "user_a", null: false
    t.integer "user_b", null: false
  end

  create_table "identities", force: :cascade do |t|
    t.bigint "user_id"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "token"
    t.datetime "token_expires"
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "path"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "profile_picture"
    t.index ["resource_type", "resource_id"], name: "index_images_on_resource_type_and_resource_id"
  end

  create_table "list_contents", force: :cascade do |t|
    t.bigint "list_id"
    t.bigint "achievement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_id"], name: "index_list_contents_on_achievement_id"
    t.index ["list_id"], name: "index_list_contents_on_list_id"
  end

  create_table "lists", force: :cascade do |t|
    t.string "title"
    t.bigint "user_id"
    t.boolean "is_public", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "to_tsvector('english'::regconfig, (title)::text)", name: "index_lists_on_title", using: :gin
    t.index ["user_id"], name: "index_lists_on_user_id"
  end

  create_table "modes", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.decimal "multiplier"
    t.integer "icon"
    t.date "time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["icon"], name: "index_modes_on_icon"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "from_id"
    t.boolean "seen"
    t.string "target_type"
    t.bigint "target_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "kind"
    t.index ["from_id"], name: "index_notifications_on_from_id"
    t.index ["target_type", "target_id"], name: "index_notifications_on_target_type_and_target_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "objective_progresses", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "objective_id"
    t.boolean "completed"
    t.integer "current_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["objective_id"], name: "index_objective_progresses_on_objective_id"
    t.index ["user_id"], name: "index_objective_progresses_on_user_id"
  end

  create_table "objectives", force: :cascade do |t|
    t.string "tagline"
    t.integer "base_points"
    t.integer "required_count"
    t.boolean "is_public", default: false
    t.integer "kind"
    t.integer "time_constraint"
    t.datetime "from_timestamp"
    t.datetime "to_timestamp"
    t.float "lat"
    t.float "lng"
    t.float "alt"
    t.bigint "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hash_identifier"
    t.index ["country_id"], name: "index_objectives_on_country_id"
    t.index ["from_timestamp"], name: "index_objectives_on_from_timestamp"
    t.index ["kind"], name: "index_objectives_on_kind"
    t.index ["lat", "lng"], name: "index_objectives_on_lat_and_lng"
    t.index ["lng", "lat"], name: "index_objectives_on_lng_and_lat"
    t.index ["time_constraint"], name: "index_objectives_on_time_constraint"
    t.index ["to_timestamp"], name: "index_objectives_on_to_timestamp"
  end

  create_table "regions", force: :cascade do |t|
    t.string "name"
    t.bigint "continent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["continent_id"], name: "index_regions_on_continent_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "permission_level"
    t.string "img_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shared_achievements", force: :cascade do |t|
    t.bigint "achievement_id"
    t.bigint "user_id"
    t.boolean "request_coop"
    t.boolean "can_invite"
    t.integer "target_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_id"], name: "index_shared_achievements_on_achievement_id"
    t.index ["target_id"], name: "index_shared_achievements_on_target_id"
    t.index ["user_id"], name: "index_shared_achievements_on_user_id"
  end

  create_table "shared_lists", force: :cascade do |t|
    t.bigint "list_id"
    t.bigint "user_id"
    t.boolean "request_coop"
    t.boolean "can_invite"
    t.boolean "is_collaborative"
    t.integer "target_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id"], name: "index_shared_lists_on_list_id"
    t.index ["target_id"], name: "index_shared_lists_on_target_id"
    t.index ["user_id"], name: "index_shared_lists_on_user_id"
  end

  create_table "titles", force: :cascade do |t|
    t.string "name"
    t.bigint "achievement_id"
    t.integer "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_id"], name: "index_titles_on_achievement_id"
  end

  create_table "trackeds", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "achievement_id"
    t.boolean "pinned"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_id"], name: "index_trackeds_on_achievement_id"
    t.index ["user_id"], name: "index_trackeds_on_user_id"
  end

  create_table "types", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "points"
    t.integer "icon"
    t.date "time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "objective_type"
    t.index ["icon"], name: "index_types_on_icon"
  end

  create_table "unlockeds", force: :cascade do |t|
    t.integer "points"
    t.integer "coop_bonus"
    t.bigint "user_id"
    t.bigint "achievement_id"
    t.boolean "coop"
    t.bigint "verification_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_id"], name: "index_unlockeds_on_achievement_id"
    t.index ["user_id"], name: "index_unlockeds_on_user_id"
    t.index ["verification_id"], name: "index_unlockeds_on_verification_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password"
    t.string "password_digest"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "personal_points"
    t.integer "points"
    t.bigint "role_id"
    t.bigint "country_id"
    t.float "scan_radius"
    t.string "authentication_token"
    t.boolean "auto_share"
    t.text "avatar"
    t.boolean "allow_coop"
    t.string "avatar_url"
    t.index "to_tsvector('english'::regconfig, (name)::text)", name: "index_users_on_name", using: :gin
    t.index ["country_id"], name: "index_users_on_country_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["personal_points"], name: "index_users_on_personal_points"
    t.index ["points"], name: "index_users_on_points"
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  create_table "verifications", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_verifications_on_user_id"
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "achievement_id"
    t.bigint "user_id"
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_id"], name: "index_votes_on_achievement_id"
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "followed_lists", "lists"
  add_foreign_key "followed_lists", "users"
  add_foreign_key "votes", "achievements"
  add_foreign_key "votes", "users"
end
