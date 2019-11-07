class CreateBooks < ActiveRecord::Migration[6.0]
  def change
    create_table :books do |t|
      t.integer :source_id
      t.string :source, null: false
      t.string :title, null: false
      t.integer :isbn, null: false, limit: 8 # 8 bytes for bigint
      t.integer :isbn13, null: false, limit: 8 # 8 bytes for bigint
      t.integer :published_year, null: false, limit: 8 # 8 bytes for bigint
      t.string :publisher
      t.string :cover_url
      t.text :description
      t.string :language
      t.text :searchable_tags, array: true, default: []

      t.timestamps
    end

    add_index :books, :title
    add_index :books, [:source, :source_id], unique: true
    add_index :books, :isbn, unique: true
  end
end
