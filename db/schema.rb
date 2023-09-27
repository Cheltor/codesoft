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

ActiveRecord::Schema[7.0].define(version: 2023_09_27_172224) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "pid"
    t.string "ownername"
    t.string "owneraddress"
    t.string "ownercity"
    t.string "ownerstate"
    t.string "ownerzip"
    t.string "streetnumb"
    t.string "streetname"
    t.string "streettype"
    t.string "landusecode"
    t.string "zoning"
    t.string "owneroccupiedin"
    t.string "vacant"
    t.string "absent"
    t.string "premisezip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "combadd"
    t.boolean "outstanding", default: false
  end

  create_table "area_codes", force: :cascade do |t|
    t.integer "area_id", null: false
    t.integer "code_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_area_codes_on_area_id"
    t.index ["code_id"], name: "index_area_codes_on_code_id"
  end

  create_table "areas", force: :cascade do |t|
    t.string "name"
    t.text "notes"
    t.string "photos"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "inspection_id", null: false
    t.index ["inspection_id"], name: "index_areas_on_inspection_id"
  end

  create_table "businesses", force: :cascade do |t|
    t.string "name"
    t.integer "address_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_businesses_on_address_id"
  end

  create_table "citations", force: :cascade do |t|
    t.integer "fine"
    t.date "deadline"
    t.integer "violation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "status"
    t.date "trial_date"
    t.integer "code_id", null: false
    t.string "citationid"
    t.integer "unit_id"
    t.index ["code_id"], name: "index_citations_on_code_id"
    t.index ["unit_id"], name: "index_citations_on_unit_id"
    t.index ["user_id"], name: "index_citations_on_user_id"
    t.index ["violation_id"], name: "index_citations_on_violation_id"
  end

  create_table "citations_codes", id: false, force: :cascade do |t|
    t.integer "citation_id", null: false
    t.integer "code_id", null: false
  end

  create_table "codes", force: :cascade do |t|
    t.string "chapter"
    t.string "section"
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.text "content"
    t.integer "address_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "unit_id"
    t.index ["address_id"], name: "index_comments_on_address_id"
    t.index ["unit_id"], name: "index_comments_on_unit_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "concerns", force: :cascade do |t|
    t.integer "address_id", null: false
    t.text "content"
    t.string "emailorphone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_concerns_on_address_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes", default: ""
  end

  create_table "inspection_codes", force: :cascade do |t|
    t.integer "inspection_id", null: false
    t.integer "code_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code_id"], name: "index_inspection_codes_on_code_id"
    t.index ["inspection_id"], name: "index_inspection_codes_on_inspection_id"
  end

  create_table "inspections", force: :cascade do |t|
    t.string "source"
    t.string "status"
    t.string "attachments"
    t.string "result"
    t.text "description"
    t.text "thoughts"
    t.string "originator"
    t.integer "unit_id"
    t.integer "address_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "assignee"
    t.integer "inspector_id"
    t.string "name"
    t.string "email"
    t.string "phone"
    t.datetime "scheduled_datetime"
    t.string "photos"
    t.text "notes_area_1"
    t.text "notes_area_2"
    t.text "notes_area_3"
    t.string "intphotos"
    t.string "extphotos"
    t.integer "contact_id"
    t.string "new_contact_name"
    t.string "new_contact_email"
    t.string "new_contact_phone"
    t.string "new_chapter"
    t.string "new_section"
    t.string "new_name"
    t.string "new_description"
    t.index ["address_id"], name: "index_inspections_on_address_id"
    t.index ["contact_id"], name: "index_inspections_on_contact_id"
    t.index ["inspector_id"], name: "index_inspections_on_inspector_id"
    t.index ["unit_id"], name: "index_inspections_on_unit_id"
  end

  create_table "units", force: :cascade do |t|
    t.string "number"
    t.integer "address_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_units_on_address_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "phone"
    t.integer "role", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "violation_codes", force: :cascade do |t|
    t.integer "violation_id", null: false
    t.integer "code_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code_id"], name: "index_violation_codes_on_code_id"
    t.index ["violation_id"], name: "index_violation_codes_on_violation_id"
  end

  create_table "violations", force: :cascade do |t|
    t.string "description"
    t.integer "status"
    t.integer "address_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "deadline"
    t.string "violation_type"
    t.integer "extend", default: 0
    t.integer "unit_id"
    t.integer "inspection_id"
    t.index ["address_id"], name: "index_violations_on_address_id"
    t.index ["inspection_id"], name: "index_violations_on_inspection_id"
    t.index ["unit_id"], name: "index_violations_on_unit_id"
    t.index ["user_id"], name: "index_violations_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "area_codes", "areas"
  add_foreign_key "area_codes", "codes"
  add_foreign_key "areas", "inspections"
  add_foreign_key "businesses", "addresses"
  add_foreign_key "citations", "codes"
  add_foreign_key "citations", "units"
  add_foreign_key "citations", "users"
  add_foreign_key "citations", "violations"
  add_foreign_key "comments", "addresses"
  add_foreign_key "comments", "units"
  add_foreign_key "comments", "users"
  add_foreign_key "concerns", "addresses"
  add_foreign_key "inspection_codes", "codes"
  add_foreign_key "inspection_codes", "inspections"
  add_foreign_key "inspections", "addresses"
  add_foreign_key "inspections", "contacts"
  add_foreign_key "inspections", "units"
  add_foreign_key "inspections", "users", column: "inspector_id"
  add_foreign_key "units", "addresses"
  add_foreign_key "violation_codes", "codes"
  add_foreign_key "violation_codes", "violations"
  add_foreign_key "violations", "addresses"
  add_foreign_key "violations", "inspections"
  add_foreign_key "violations", "units"
  add_foreign_key "violations", "users"
end
