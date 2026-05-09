class UserRole < ApplicationRecord
  ROLES = %w[reporter instructor manager developer].freeze

  belongs_to :user
  belongs_to :data_provider, optional: true

  validates :role, presence: true, inclusion: { in: ROLES + %w[admin] }
  validates :data_provider_slug, presence: true, unless: :admin?
  validate :definition_belongs_to_provider, if: :authorization_definition_id?

  before_validation :sync_data_provider_slug

  scope :for_role, ->(role) { where(role: role) }
  scope :for_roles, ->(roles) { where(role: roles) }
  scope :for_provider, ->(slug) { where(data_provider_slug: slug) }
  scope :for_definition, ->(id) { where(authorization_definition_id: id) }
  scope :fd_level, -> { where(authorization_definition_id: nil).where.not(data_provider_slug: nil) }
  scope :admin_role, -> { where(role: 'admin') }
  scope :effective_for_role, ->(kind) { for_roles(RoleHierarchy.qualifying_roles(kind)) }

  scope :effective_for_definition, lambda { |definition_id|
    fd_slug = ParsedRole.resolve_provider_slug(definition_id)
    where(authorization_definition_id: definition_id)
      .or(where(data_provider_slug: fd_slug, authorization_definition_id: nil))
  }

  def fd_level?
    data_provider_slug.present? && authorization_definition_id.nil?
  end

  def covered_definition_ids
    if fd_level?
      AuthorizationDefinition.all
        .select { |ad| ad.provider_slug == data_provider_slug }
        .map(&:id)
    else
      [authorization_definition_id]
    end
  end

  def admin?
    role == 'admin'
  end

  private

  def sync_data_provider_slug
    self.data_provider_slug = data_provider&.slug if data_provider_id.present?
  end

  def definition_belongs_to_provider
    actual_provider = ParsedRole.resolve_provider_slug(authorization_definition_id)
    return unless actual_provider
    return if actual_provider == data_provider_slug

    errors.add(:authorization_definition_id, 'does not belong to this provider')
  end
end
