class CreateBooks < ActiveRecord::Migration[6.0]
  def change
    create_table :books do |t|
      t.integer :goodreads_id
      t.string :title, null: false
      t.string :author, null: false
      t.integer :isbn, null: false
      t.integer :published_year, null: false
      t.string :publisher
      t.string :cover_url
      t.text :description
      t.string :language

      t.timestamps
    end

    add_index :books, [:title, :author], unique: true
    add_index :books, :goodreads_id, unique: true
    add_index :books, :isbn, unique: true
  end
end
