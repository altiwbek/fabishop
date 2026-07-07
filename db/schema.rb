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

ActiveRecord::Schema[8.1].define(version: 2026_07_05_221734) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "brands", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.integer "products_count", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["slug"], name: "index_brands_on_slug", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "featured", default: false, null: false
    t.string "name", null: false
    t.bigint "parent_id"
    t.integer "position", default: 0, null: false
    t.integer "products_count", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["position"], name: "index_categories_on_position"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "collection_products", force: :cascade do |t|
    t.bigint "collection_id", null: false
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id", "product_id"], name: "index_collection_products_on_collection_id_and_product_id", unique: true
    t.index ["collection_id"], name: "index_collection_products_on_collection_id"
    t.index ["product_id"], name: "index_collection_products_on_product_id"
  end

  create_table "collections", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "featured", default: false, null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.string "subtitle"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_collections_on_slug", unique: true
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.bigint "product_id"
    t.string "product_name", null: false
    t.integer "quantity", default: 1, null: false
    t.string "sku"
    t.decimal "unit_price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "address"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.text "notes"
    t.string "number", null: false
    t.string "phone"
    t.string "postal_code"
    t.decimal "shipping", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "status", default: 0, null: false
    t.decimal "subtotal", precision: 10, scale: 2, default: "0.0", null: false
    t.string "token", null: false
    t.decimal "total", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_orders_on_number", unique: true
    t.index ["status"], name: "index_orders_on_status"
    t.index ["token"], name: "index_orders_on_token", unique: true
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.text "excerpt"
    t.boolean "published", default: false, null: false
    t.datetime "published_at"
    t.string "slug", null: false
    t.string "subtitle"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "views_count", default: 0, null: false
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["published_at"], name: "index_posts_on_published_at"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.bigint "brand_id"
    t.bigint "category_id", null: false
    t.decimal "compare_at_price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.boolean "featured", default: false, null: false
    t.string "name", null: false
    t.boolean "new_arrival", default: false, null: false
    t.boolean "on_sale", default: false, null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.boolean "published", default: false, null: false
    t.datetime "published_at"
    t.decimal "rating", precision: 3, scale: 2, default: "0.0", null: false
    t.integer "reviews_count", default: 0, null: false
    t.string "sku"
    t.string "slug", null: false
    t.integer "stock", default: 0, null: false
    t.string "subtitle"
    t.datetime "updated_at", null: false
    t.integer "views_count", default: 0, null: false
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["featured"], name: "index_products_on_featured"
    t.index ["published"], name: "index_products_on_published"
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end

  create_table "reviews", force: :cascade do |t|
    t.boolean "approved", default: false, null: false
    t.string "author_email"
    t.string "author_name", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "helpful_count", default: 0, null: false
    t.bigint "product_id", null: false
    t.integer "rating", default: 5, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["approved"], name: "index_reviews_on_approved"
    t.index ["product_id"], name: "index_reviews_on_product_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "slides", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "button_label"
    t.string "button_url"
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.string "price"
    t.string "price_label"
    t.string "subtitle"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "index_slides_on_position"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name", default: "", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "collection_products", "collections"
  add_foreign_key "collection_products", "products"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products", on_delete: :nullify
  add_foreign_key "posts", "users", column: "author_id"
  add_foreign_key "products", "brands"
  add_foreign_key "products", "categories"
  add_foreign_key "reviews", "products"
  add_foreign_key "sessions", "users"
end
