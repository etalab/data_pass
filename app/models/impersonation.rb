class Impersonation < ApplicationRecord
  belongs_to :user
  belongs_to :admin, class_name: 'User'

  has_many :actions, class_name: 'ImpersonationAction', dependent: :destroy

  validates :reason, presence: true
  validate :user_and_admin_must_be_different

  scope :active, -> { where(finished_at: nil) }
  scope :finished, -> { where.not(finished_at: nil) }

  def active?
    finished_at.nil?
  end

  def finish!
    update!(finished_at: Time.current)
  end

  private

  def user_and_admin_must_be_different
    return unless user_id && admin_id

    errors.add(:user, :cannot_be_same_as_admin) if user_id == admin_id
  end
end
