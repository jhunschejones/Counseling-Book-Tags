class ChangeBigintsToStrings < ActiveRecord::Migration[6.0]
  def change
    change_column :books, :published_year, :string
    change_column :books, :isbns, :string, array: true, default: []
  end
end
