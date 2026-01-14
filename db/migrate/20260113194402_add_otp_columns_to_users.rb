class AddOtpColumnsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email_verified, :boolean, default: false
    add_column :users, :otp_code, :string
    add_column :users, :otp_expires_at, :datetime
  end
end
