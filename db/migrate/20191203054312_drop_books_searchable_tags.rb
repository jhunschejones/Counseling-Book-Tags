class DropBooksSearchableTags < ActiveRecord::Migration[6.0]
  def change
    remove_column :books, :searchable_tags
  end
end
