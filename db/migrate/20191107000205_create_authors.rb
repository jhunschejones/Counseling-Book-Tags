class CreateAuthors < ActiveRecord::Migration[6.0]
  def change
    create_table :authors do |t|
      t.string :name, null: false
      t.string :source, null: false
      t.integer :source_id, limit: 8 # 8 bytes for bigint
      t.string :image

      t.timestamps
    end

    add_index :authors, :name
    add_index :authors, [:source, :source_id], unique: true
  end
end
