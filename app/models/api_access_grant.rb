class APIAccessGrant < ApplicationRecord
  enum :action, APIScopes::BY_ACTION.keys.index_with(&:itself), prefix: true, validate: true

  belongs_to :oauth_application, class_name: 'Doorkeeper::Application', optional: true
  belongs_to :data_provider

  before_validation :copy_application_name, :set_granted_at, on: :create
  after_destroy :sync_application_scopes

  validates :oauth_application, presence: true, on: :create
  validates :granted_by_email, :grant_reason, :granted_at, presence: true
  validates :revoke_reason, presence: true, if: :revoked_at?
  validates :revoked_by_email, presence: true, if: :revoked_by_a_person?
  validate :no_other_active_grant, if: :active?
  validate :owner_covers_data_provider, on: :create

  scope :active, -> { where(revoked_at: nil) }

  def self.provider_slugs_covered_by_owner_of(application)
    owner = application&.owner
    return [] unless owner

    owner.roles_for(:developer).provider_slugs
  end

  def self.active_for?(application:, data_provider_id:, action:)
    return false if application.nil? || data_provider_id.nil?

    active.exists?(oauth_application_id: application.id, data_provider_id:, action:)
  end

  def scope_name
    APIScopes::BY_ACTION.fetch(action)
  end

  def active?
    revoked_at.nil?
  end

  def revoke!(by_email:, reason:, by_id: nil)
    revoke_once(revoked_by_id: by_id, revoked_by_email: by_email, revoke_reason: reason)
  end

  def revoke_automatically!(reason:)
    revoke_once(revoked_automatically: true, revoke_reason: reason)
  end

  private

  def sync_application_scopes
    Admin::SyncAPIAccessScopes.call!(grant: self)
  end

  def revoked_by_a_person?
    revoked_at? && !revoked_automatically?
  end

  def revoke_once(attributes)
    with_lock do
      next already_revoked_failure unless active?

      revoke_with(attributes)
    end
  end

  def revoke_with(attributes)
    return true if update(attributes.merge(revoked_at: Time.current))

    restore_attributes
    false
  end

  def already_revoked_failure
    errors.add(:base, :already_revoked)
    false
  end

  def copy_application_name
    self.oauth_application_name ||= oauth_application&.name
  end

  def set_granted_at
    self.granted_at ||= Time.current
  end

  def no_other_active_grant
    return unless self.class.active.where.not(id:).exists?(oauth_application_id:, data_provider_id:, action:)

    errors.add(:base, :already_granted)
  end

  def owner_covers_data_provider
    return if data_provider.nil?

    return if self.class.provider_slugs_covered_by_owner_of(oauth_application).include?(data_provider.slug)

    errors.add(:base, :not_covered_by_owner)
  end
end
