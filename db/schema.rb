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

ActiveRecord::Schema[7.1].define(version: 2026_03_25_150923) do
  create_table "entrees", force: :cascade do |t|
    t.integer "journee_observation_id", null: false
    t.time "heure", null: false
    t.integer "volume_boisson"
    t.integer "volume_urine"
    t.string "urgenturies"
    t.string "fuites"
    t.string "commentaires", limit: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "intervalle_mictionnel"
    t.index ["journee_observation_id"], name: "index_entrees_on_journee_observation_id"
  end

  create_table "journee_observations", force: :cascade do |t|
    t.date "date_observation", null: false
    t.time "heure_lever"
    t.time "heure_coucher"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "entrees", "journee_observations"
end
