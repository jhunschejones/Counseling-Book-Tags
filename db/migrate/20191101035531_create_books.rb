class CreateBooks < ActiveRecord::Migration[6.0]
  def change
    create_table :books do |t|
      t.integer :source_id
      t.string :source, null: false
      t.string :title, null: false
      t.string :authors, null: false, array: true
      t.integer :isbn, null: false
      t.integer :isbn13, null: false
      t.integer :published_year, null: false
      t.string :publisher
      t.string :cover_url
      t.text :description
      t.string :language

      t.timestamps
    end

    add_index :books, [:title, :authors], unique: true
    add_index :books, [:source, :source_id], unique: true
    add_index :books, :isbn, unique: true
  end
end
