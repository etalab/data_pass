class Impersonation < ApplicationRecord
  CREATED_AT_OFFSET = 1.hour

  belongs_to :user
  belongs_to :admin,
    class_name: 'User'

  has_many :actions,
    class_name: 'ImpersonationAction',
    dependent: :destroy

  validates :reason, presence: true

  validate :user_and_admin_must_be_different
  validate :user_is_not_admin
  validate :admin_is_an_admin

  scope :active, -> { where(finished_at: nil, created_at: (..CREATED_AT_OFFSET)) }

  def active?
    finished_at.nil? &&
      created_at > CREATED_AT_OFFSET.ago
  end

  def finish!
    update!(finished_at: Time.current)
  end

  private

  def user_and_admin_must_be_different
    return unless user_id && admin_id

    errors.add(:user, :cannot_be_same_as_admin) if user_id == admin_id
  end

  def user_is_not_admin
    return unless user_id

    errors.add(:user, :cannot_be_admin) if user.admin?
  end

  def admin_is_an_admin
    return unless admin_id

    errors.add(:admin, :must_be_admin) unless admin.admin?
  end
end
