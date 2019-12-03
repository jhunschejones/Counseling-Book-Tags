class FixColumBooleanNames < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :verified, :is_verified
  end
end
