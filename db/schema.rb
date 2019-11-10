# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_10_201838) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authors", force: :cascade do |t|
    t.string "name", null: false
    t.string "source", null: false
    t.string "source_id"
    t.string "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_authors_on_name"
    t.index ["source", "source_id"], name: "index_authors_on_source_and_source_id", unique: true
  end

  create_table "authors_books", id: false, force: :cascade do |t|
    t.bigint "book_id", null: false
    t.bigint "author_id", null: false
    t.index ["author_id"], name: "index_authors_books_on_author_id"
    t.index ["book_id"], name: "index_authors_books_on_book_id"
  end

  create_table "books", force: :cascade do |t|
    t.string "source_id"
    t.string "source", null: false
    t.string "title", null: false
    t.bigint "isbn"
    t.bigint "isbn13"
    t.string "published_year"
    t.string "publisher"
    t.string "cover_url"
    t.text "description"
    t.string "language"
    t.string "searchable_tags", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "isbns", default: [], array: true
    t.index ["source", "source_id"], name: "index_books_on_source_and_source_id", unique: true
    t.index ["title"], name: "index_books_on_title"
  end

  create_table "tags", force: :cascade do |t|
    t.string "text", null: false
    t.bigint "user_id", null: false
    t.bigint "book_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["book_id"], name: "index_tags_on_book_id"
    t.index ["text", "user_id", "book_id"], name: "index_tags_on_text_and_user_id_and_book_id", unique: true
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "email_verification_token"
    t.datetime "email_verification_sent_at"
    t.string "unconfirmed_email"
    t.boolean "verified", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "tags", "books"
  add_foreign_key "tags", "users"
end
