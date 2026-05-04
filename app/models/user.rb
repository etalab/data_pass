class User < ApplicationRecord
  self.ignored_columns += %w[current_organization_id]

  include NotificationsSettings

  ROLES = %w[reporter instructor manager developer].freeze

  validates :email,
    presence: true,
    uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }

  before_save { email.downcase! }

  validates :external_id, uniqueness: true, allow_nil: true

  validates :ban_reason, presence: true, if: :banned?

  has_many :organizations_users,
    dependent: :destroy

  has_many :organizations, through: :organizations_users

  has_one :current_organization_user,
    -> { current },
    class_name: 'OrganizationsUser',
    dependent: :nullify,
    inverse_of: :user

  has_one :current_organization,
    through: :current_organization_user,
    source: :organization

  def current_organization_verified?
    current_organization_user&.verified? || false
  end

  def current_identity_provider
    return IdentityProvider.unknown if current_organization_user.blank?

    current_organization_user.identity_provider
  end

  has_many :authorization_requests_as_applicant,
    dependent: :restrict_with_exception,
    class_name: 'AuthorizationRequest',
    inverse_of: :applicant

  has_many :authorizations_as_applicant,
    dependent: :restrict_with_exception,
    class_name: 'Authorization',
    inverse_of: :applicant

  has_many :admin_events,
    inverse_of: :admin,
    dependent: :restrict_with_exception

  has_many :user_roles, dependent: :destroy

  scope :with_roles, -> { where(id: UserRole.select(:user_id)) }
  scope :banned, -> { where.not(banned_at: nil) }

  %i[instructor developer manager reporter].each do |role|
    scope :"#{role}_for", lambda { |type|
      joins(:user_roles).merge(
        UserRole.effective_for_role(role).effective_for_definition(type.underscore)
      ).distinct
    }
  end

  scope :admin, -> { joins(:user_roles).merge(UserRole.admin_role).distinct }

  add_instruction_boolean_settings :submit_notifications, :messages_notifications

  has_many :oauth_applications,
    class_name: 'Doorkeeper::Application',
    as: :owner,
    dependent: :restrict_with_exception

  has_many :access_grants,
    class_name: 'Doorkeeper::AccessGrant',
    foreign_key: :resource_owner_id,
    inverse_of: :resource_owner,
    dependent: :delete_all

  has_many :access_tokens,
    class_name: 'Doorkeeper::AccessToken',
    foreign_key: :resource_owner_id,
    inverse_of: :resource_owner,
    dependent: :delete_all

  def banned?
    banned_at.present?
  end

  def full_name
    return email unless family_name.present? && given_name.present?

    formatted_given_name = given_name.gsub(/\b\w+/) { |word| word.downcase.capitalize }
    "#{family_name.upcase} #{formatted_given_name}"
  end

  def roles_for(kind)
    @role_sets ||= {}
    @role_sets[kind] ||= RoleSet.new(user_roles, kind)
  end

  def instructor?(definition_id = nil)
    roles_for(:instructor).covers?(definition_id)
  end

  def manager?(definition_id = nil)
    roles_for(:manager).covers?(definition_id)
  end

  def reporter?(definition_id = nil)
    return true if admin?

    roles_for(:reporter).covers?(definition_id)
  end

  def developer?
    roles_for(:developer).any?
  end

  def definition_ids_for(kind)
    roles_for(kind).definition_ids
  end

  def authorization_request_types_for(kind)
    roles_for(kind).authorization_request_types
  end

  def authorization_definition_roles_as(kind)
    roles_for(kind).authorization_definitions
  end

  def grant_role(kind, definition_id)
    fd = ParsedRole.resolve_provider_slug(definition_id)
    raise ParsedRole::UnknownDefinitionError, "Unknown definition: #{definition_id}" unless fd

    dp = DataProvider.find_by(slug: fd)
    user_roles.find_or_create_by!(role: kind.to_s, data_provider: dp, data_provider_slug: fd, authorization_definition_id: definition_id)
    @role_sets = nil
  end

  def grant_fd_role(kind, provider_slug)
    dp = DataProvider.find_by(slug: provider_slug)
    user_roles.find_or_create_by!(role: kind.to_s, data_provider: dp, data_provider_slug: provider_slug, authorization_definition_id: nil)
    @role_sets = nil
  end

  def grant_admin_role
    user_roles.find_or_create_by!(role: 'admin')
    @role_sets = nil
  end

  def revoke_all_roles
    user_roles.destroy_all
    @role_sets = nil
  end

  def admin?
    user_roles.admin_role.exists? ||
      bug_bounty_users_within_staging_env?
  end

  def bug_bounty_users_within_staging_env?
    Rails.env.staging? &&
      /-ywhadmin@yopmail.com$/.match?(email)
  end

  def roles_as_strings
    user_roles.map do |ur|
      if ur.admin?
        'admin'
      elsif ur.fd_level?
        "#{ur.data_provider_slug}:*:#{ur.role}"
      else
        "#{ur.data_provider_slug}:#{ur.authorization_definition_id}:#{ur.role}"
      end
    end
  end

  def roles
    roles_as_strings
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      family_name
      given_name
      email
      api_role
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[
      organizations
    ]
  end

  ransacker :api_role do |_parent|
    Arel.sql(api_role_ransacker_sql)
  end

  def self.api_role_ransacker_sql
    <<~SQL.squish
      COALESCE(
        (SELECT string_agg(DISTINCT def_id, ',') FROM (
          SELECT ur.authorization_definition_id AS def_id
          FROM user_roles ur
          WHERE ur.user_id = users.id AND ur.authorization_definition_id IS NOT NULL
          #{api_role_fd_expansion_sql}
        ) expanded),
        ''
      )
    SQL
  end

  def self.api_role_fd_expansion_sql
    all_definitions = AuthorizationDefinition.all.select(&:provider_slug)
    values = all_definitions.map { |ad|
      "(#{connection.quote(ad.id)}, #{connection.quote(ad.provider_slug)})"
    }.join(', ')

    return '' if values.blank?

    <<~SQL.squish
      UNION
      SELECT ad_map.def_id
      FROM user_roles ur
      JOIN (VALUES #{values}) AS ad_map(def_id, provider_slug)
        ON ad_map.provider_slug = ur.data_provider_slug
      WHERE ur.user_id = users.id AND ur.authorization_definition_id IS NULL
    SQL
  end

  def current_organization=(organization)
    return if organization.nil?

    organization_user = organizations_users.find_or_initialize_by(organization:)
    organization_user.set_as_current! if organization_user.persisted?
  end

  def add_to_organization(organization, **options)
    defaults = { verified: false, identity_federator: 'unknown', current: false }
    opts = defaults.merge(options)

    organizations_users.find_or_create_by(organization:).tap do |org_user|
      updates = opts.slice(:identity_federator, :verified, :verified_reason).compact
      updates[:identity_provider_uid] = opts[:identity_provider_uid]
      org_user.update!(updates) if updates.any?
      org_user.set_as_current! if opts[:current]
    end
  end
end
