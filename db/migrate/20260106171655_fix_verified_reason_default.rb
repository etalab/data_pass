class FixVerifiedReasonDefault < ActiveRecord::Migration[8.1]
  def up
    change_column_default :organizations_users, :verified_reason, nil
    change_column_null :organizations_users, :verified_reason, true

    OrganizationsUser.where(verified: false).update_all(verified_reason: nil)
  end

  def down
    change_column_default :organizations_users, :verified_reason, 'from ProConnect identity'
    change_column_null :organizations_users, :verified_reason, false
  end
end
