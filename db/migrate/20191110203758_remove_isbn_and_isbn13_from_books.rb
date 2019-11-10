class RemoveIsbnAndIsbn13FromBooks < ActiveRecord::Migration[6.0]
  def change
    remove_column :books, :isbn, :bigint
    remove_column :books, :isbn13, :bigint
  end
end
