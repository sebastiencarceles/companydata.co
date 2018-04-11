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

ActiveRecord::Schema.define(version: 20180410160732) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "website"
    t.integer "linkedin_id"
    t.string "source_url"
    t.string "legal_form"
    t.string "category"
    t.string "staff"
    t.text "presentation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "logo_url"
    t.string "registration_1"
    t.string "registration_2"
    t.string "activity_code"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "zipcode"
    t.string "city"
    t.string "department_code"
    t.string "department"
    t.string "region"
    t.date "founded_at"
    t.string "country"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "address_line_5"
    t.string "cedex"
    t.string "quality"
    t.string "revenue"
    t.string "smooth_name"
    t.float "lat"
    t.float "lng"
    t.datetime "geolocalized_at"
    t.string "civility"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.string "linkedin"
    t.string "facebook"
    t.string "twitter"
    t.string "crunchbase"
    t.string "country_code"
    t.index ["name"], name: "index_companies_on_name"
    t.index ["quality"], name: "index_companies_on_quality"
    t.index ["registration_1", "registration_2"], name: "index_companies_on_registration_1_and_registration_2"
    t.index ["slug"], name: "index_companies_on_slug", unique: true
    t.index ["smooth_name"], name: "index_companies_on_smooth_name"
  end

  create_table "financial_years", force: :cascade do |t|
    t.string "year"
    t.string "currency"
    t.bigint "revenue"
    t.bigint "income"
    t.integer "staff"
    t.integer "duration"
    t.date "closing_date"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_financial_years_on_company_id"
    t.index ["year", "closing_date"], name: "index_financial_years_on_year_and_closing_date"
  end

  create_table "usages", force: :cascade do |t|
    t.integer "year"
    t.integer "month"
    t.integer "count", default: 0
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "year", "month"], name: "index_usages_on_user_id_and_year_and_month"
    t.index ["user_id"], name: "index_usages_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_key"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "free_calls_count", default: 100
    t.boolean "terms_of_service", default: false
    t.index ["api_key"], name: "index_users_on_api_key", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vats", force: :cascade do |t|
    t.bigint "company_id"
    t.string "value"
    t.string "status", default: "waiting_for_validation"
    t.datetime "validated_at"
    t.string "country_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_vats_on_company_id"
    t.index ["status"], name: "index_vats_on_status"
    t.index ["value"], name: "index_vats_on_value"
  end

  add_foreign_key "financial_years", "companies"
  add_foreign_key "usages", "users"
  add_foreign_key "vats", "companies"
end
