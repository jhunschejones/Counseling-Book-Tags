class RemoveRequiredIsbnIsbn13PublishedYear < ActiveRecord::Migration[6.0]
  def up
    change_column_null :books, :isbn, true
    change_column_null :books, :isbn13, true
    change_column_null :books, :published_year, true
    remove_index :books, name: "index_books_on_isbn"
  end

  # this rollback won't work once nulls get entered in these colums
  # but I am planning to drop the columns once everything is working
  # with the new array `isbns` field
  def down
    change_column_null :books, :isbn, false
    change_column_null :books, :isbn13, false
    change_column_null :books, :published_year, false
    add_index :books, :isbn
  end
end
