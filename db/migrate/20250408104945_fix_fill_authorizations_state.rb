class FixFillAuthorizationsState < ActiveRecord::Migration[8.0]
  # rubocop:disable Rails/SkipsModelValidations
  def up
    Authorization.where(revoked: true).update_all(state: :revoked)
  end
  # rubocop:enable Rails/SkipsModelValidations

  def down
  end
end
