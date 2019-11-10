class AddIsbnsArray < ActiveRecord::Migration[6.0]
  def change
    add_column :books, :isbns, :bigint, array: true, default: []
  end
end
