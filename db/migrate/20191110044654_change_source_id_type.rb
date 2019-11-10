class ChangeSourceIdType < ActiveRecord::Migration[6.0]
  def up
    change_column :books, :source_id, :string
    change_column :authors, :source_id, :string
  end

  # breaking forward change :(
  def down
    change_column :books, :source_id, :bigint
    change_column :authors, :source_id, :bigint
  end
end
