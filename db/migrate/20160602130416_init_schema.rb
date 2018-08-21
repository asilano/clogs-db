class InitSchema < ActiveRecord::Migration[5.1]
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"
    create_table "delayed_jobs", id: :serial, force: :cascade do |t|
      t.integer "priority", default: 0, null: false
      t.integer "attempts", default: 0, null: false
      t.text "handler", null: false
      t.text "last_error"
      t.datetime "run_at"
      t.datetime "locked_at"
      t.datetime "failed_at"
      t.string "locked_by"
      t.string "queue"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["priority", "run_at"], name: "delayed_jobs_priority"
    end
    create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
      t.string "slug", null: false
      t.integer "sluggable_id", null: false
      t.string "sluggable_type", limit: 40
      t.datetime "created_at"
      t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", unique: true
      t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
      t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
    end
    create_table "mailing_lists", id: :serial, force: :cascade do |t|
      t.string "name", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "query"
      t.index ["name"], name: "index_mailing_lists_on_name", unique: true
    end
    create_table "mailing_lists_members", id: false, force: :cascade do |t|
      t.integer "mailing_list_id"
      t.integer "member_id"
      t.index ["mailing_list_id"], name: "index_mailing_lists_members_on_mailing_list_id"
      t.index ["member_id"], name: "index_mailing_lists_members_on_member_id"
    end
    create_table "members", id: :serial, force: :cascade do |t|
      t.string "forename"
      t.string "surname"
      t.string "addr1"
      t.string "addr2"
      t.string "addr3"
      t.string "town"
      t.string "county"
      t.string "postcode"
      t.string "phone"
      t.string "mobile"
      t.string "voice"
      t.string "membership"
      t.string "email"
      t.boolean "subs_paid"
      t.boolean "show_fee_paid"
      t.boolean "concert_fee_paid"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "notes"
      t.integer "join_year"
      t.string "slug"
      t.index ["slug"], name: "index_members_on_slug", unique: true
    end
    create_table "users", id: :serial, force: :cascade do |t|
      t.string "email", default: "", null: false
      t.string "encrypted_password", default: "", null: false
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean "approved", default: false, null: false
      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
  end
end
