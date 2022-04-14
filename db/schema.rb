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

ActiveRecord::Schema.define(version: 20171012031352) do

  create_table "notifications", force: :cascade do |t|
    t.string   "transaction_code"
    t.string   "transaction_date"
    t.string   "transaction_sender_email"
    t.integer  "transaction_status"
    t.string   "transaction_cancellation_source"
    t.string   "transaction_last_event_date"
    t.string   "transaction_payment_type"
    t.string   "transaction_amount"
    t.string   "transaction_escrow_date"
    t.string   "transaction_feeAmount"
    t.integer  "transaction_reference"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "purchase_items", force: :cascade do |t|
    t.integer  "sku_id"
    t.string   "sku_description"
    t.decimal  "sku_value"
    t.integer  "purchase_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["purchase_id"], name: "index_purchase_items_on_purchase_id"
  end

  create_table "purchases", force: :cascade do |t|
    t.integer  "store_id"
    t.string   "buyer_email"
    t.string   "buyer_name"
    t.string   "payment_errors"
    t.string   "checkout_code"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

end
