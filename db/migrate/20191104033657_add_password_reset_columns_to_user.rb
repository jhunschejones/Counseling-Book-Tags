class AddPasswordResetColumnsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime
    add_column :users, :email_verification_token, :string
    add_column :users, :email_verification_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string
    add_column :users, :is_verified, :boolean, default: false
  end
end
