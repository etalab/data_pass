class AddINSEEConsecutiveFailuresToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :insee_consecutive_failures, :integer, default: 0, null: false
  end
end
