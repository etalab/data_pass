class OrganizationsUser < ApplicationRecord
  self.primary_key = %i[organization_id user_id]

  belongs_to :organization
  belongs_to :user

  validates :organization_id, uniqueness: { scope: :user_id }

  before_validation :set_default_identity_provider_uid

  scope :current, -> { where(current: true) }

  def set_as_current!
    transaction do
      # rubocop:disable Rails/SkipsModelValidations
      user.organizations_users.where(current: true).update_all(current: false)
      # rubocop:enable Rails/SkipsModelValidations
      update!(current: true)
    end
  end
end
