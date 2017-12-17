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

ActiveRecord::Schema.define(version: 20171213163701) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "website"
    t.integer "linkedin_id"
    t.string "source_url"
    t.string "headquarter_in"
    t.string "founded_in"
    t.string "legal_form"
    t.string "category"
    t.string "staff"
    t.text "specialities"
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
    t.string "geolocation"
    t.string "country"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "address_line_5"
    t.string "cedex"
    t.string "quality"
    t.string "revenue"
    t.index ["slug"], name: "index_companies_on_slug", unique: true
  end

  create_table "entreprises", id: false, force: :cascade do |t|
    t.string "siren", limit: 9
    t.string "nic", limit: 5
    t.string "l1_normalisee", limit: 38
    t.string "l2_normalisee", limit: 38
    t.string "l3_normalisee", limit: 38
    t.string "l4_normalisee", limit: 38
    t.string "l5_normalisee", limit: 38
    t.string "l6_normalisee", limit: 38
    t.string "l7_normalisee", limit: 38
    t.string "l1_declaree", limit: 38
    t.string "l2_declaree", limit: 38
    t.string "l3_declaree", limit: 38
    t.string "l4_declaree", limit: 38
    t.string "l5_declaree", limit: 38
    t.string "l6_declaree", limit: 38
    t.string "l7_declaree", limit: 38
    t.string "numvoie", limit: 4
    t.string "indrep", limit: 1
    t.string "typvoie", limit: 4
    t.string "libvoie", limit: 32
    t.string "codpos", limit: 5
    t.string "cedex", limit: 5
    t.string "rpet", limit: 2
    t.string "libreg", limit: 70
    t.string "depet", limit: 2
    t.string "arronet", limit: 2
    t.string "ctonet", limit: 3
    t.string "comet", limit: 3
    t.string "libcom", limit: 32
    t.string "du", limit: 2
    t.string "tu", limit: 1
    t.string "uu", limit: 2
    t.string "epci", limit: 9
    t.string "tcd", limit: 2
    t.string "zemet", limit: 4
    t.string "siege", limit: 1
    t.string "enseigne", limit: 40
    t.string "ind_publipo", limit: 1
    t.string "diffcom", limit: 1
    t.string "amintret", limit: 6
    t.string "natetab", limit: 1
    t.string "libnatetab", limit: 30
    t.string "apet700", limit: 5
    t.string "libapet", limit: 65
    t.integer "dapet", limit: 2
    t.string "tefet", limit: 2
    t.string "libtefet", limit: 23
    t.string "efetcent", limit: 6
    t.integer "defet", limit: 2
    t.string "origine", limit: 2
    t.string "dcret", limit: 8
    t.string "date_deb_etat_adm_et", limit: 8
    t.string "activnat", limit: 2
    t.string "lieuact", limit: 2
    t.string "actisurf", limit: 2
    t.string "saisonat", limit: 2
    t.string "modet", limit: 1
    t.string "prodet", limit: 1
    t.string "prodpart", limit: 1
    t.integer "auxilt", limit: 2
    t.string "nomen_long", limit: 131
    t.string "sigle", limit: 20
    t.string "nom", limit: 100
    t.string "prenom", limit: 30
    t.string "civilite", limit: 1
    t.string "rna", limit: 10
    t.string "nicsiege", limit: 5
    t.string "rpen", limit: 2
    t.string "depcomen", limit: 5
    t.string "adr_mail", limit: 80
    t.string "nj", limit: 4
    t.string "libnj", limit: 100
    t.string "apen700", limit: 5
    t.string "libapen", limit: 65
    t.integer "dapen", limit: 2
    t.string "aprm", limit: 6
    t.string "essen", limit: 1
    t.string "dateess", limit: 8
    t.string "tefen", limit: 2
    t.string "libtefen", limit: 23
    t.string "efencent", limit: 6
    t.integer "defen", limit: 2
    t.string "categorie", limit: 5
    t.string "dcren", limit: 8
    t.string "amintren", limit: 6
    t.string "monoact", limit: 1
    t.string "moden", limit: 1
    t.string "proden", limit: 1
    t.integer "esaann", limit: 2
    t.string "tca", limit: 1
    t.string "esaapen", limit: 5
    t.string "esasec1n", limit: 5
    t.string "esasec2n", limit: 5
    t.string "esasec3n", limit: 5
    t.string "esasec4n", limit: 5
    t.string "vmaj", limit: 1
    t.integer "vmaj1", limit: 2
    t.integer "vmaj2", limit: 2
    t.integer "vmaj3", limit: 2
    t.string "datemaj", limit: 100
  end

  create_table "tests", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
