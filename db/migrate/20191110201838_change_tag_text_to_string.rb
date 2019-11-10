class ChangeTagTextToString < ActiveRecord::Migration[6.0]
  def change
    change_column :books, :searchable_tags, :string, array: true, default: []
  end
end
