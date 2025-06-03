class OrganizationsUser < ApplicationRecord
  self.primary_key = %i[organization_id user_id]

  belongs_to :organization
  belongs_to :user

  validates :organization_id, uniqueness: { scope: :user_id }

  scope :current, -> { where(current: true) }

  def set_as_current!
    transaction do
      # rubocop:disable Rails/SkipsModelValidations
      user.organizations_users.where.not(organization_id: organization_id).where(current: true).update_all(current: false)
      # rubocop:enable Rails/SkipsModelValidations
      update!(current: true) unless current?
    end
  end
end
