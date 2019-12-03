class CreateBooks < ActiveRecord::Migration[6.0]
  def change
    create_table :books do |t|
      t.string :source_id
      t.string :source, null: false
      t.string :title, null: false
      t.string :published_year
      t.string :publisher
      t.string :cover_url
      t.text :description
      t.string :language
      t.string :isbns, array: true, default: []

      t.timestamps
    end

    add_index :books, :title
    add_index :books, [:source, :source_id], unique: true
  end
end
