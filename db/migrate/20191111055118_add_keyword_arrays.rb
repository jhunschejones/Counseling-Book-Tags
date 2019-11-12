class AddKeywordArrays < ActiveRecord::Migration[6.0]
  def change
    add_column :books, :title_keywords, :string, array: true, default: []
    add_column :authors, :name_keywords, :string, array: true, default: []
  end
end
