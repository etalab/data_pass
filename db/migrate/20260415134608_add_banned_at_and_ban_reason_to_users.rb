class AddBannedAtAndBanReasonToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :banned_at, :datetime
    add_column :users, :ban_reason, :text
  end
end
