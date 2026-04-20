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

  scope :with_roles, -> { where("roles <> '{}'") }
  scope :banned, -> { where.not(banned_at: nil) }

  scope :instructor_for, lambda { |authorization_request_type|
    qualifying = RoleHierarchy.qualifying_roles(:instructor)
    where(
      'EXISTS (SELECT 1 FROM unnest(roles) AS role WHERE role IN (?))',
      qualifying.map { |q| "#{authorization_request_type.underscore}:#{q}" }
    )
  }

  scope :developer_for, lambda { |authorization_request_type|
    where(
      'EXISTS (SELECT 1 FROM unnest(roles) AS role WHERE role = ?)',
      "#{authorization_request_type.underscore}:developer"
    )
  }

  scope :manager_for, lambda { |authorization_request_type|
    where(
      'EXISTS (SELECT 1 FROM unnest(roles) AS role WHERE role = ?)',
      "#{authorization_request_type.underscore}:manager"
    )
  }

  scope :reporter_for, lambda { |authorization_request_type|
    qualifying = RoleHierarchy.qualifying_roles(:reporter)
    where(
      'EXISTS (SELECT 1 FROM unnest(roles) AS role WHERE role IN (?))',
      qualifying.map { |q| "#{authorization_request_type.underscore}:#{q}" }
    )
  }

  scope :admin, lambda {
    where("'admin' = ANY(roles)")
  }

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
    @role_sets[kind] ||= RoleSet.new(roles, kind)
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

  def admin?
    roles.include?('admin') ||
      bug_bounty_users_within_staging_env?
  end

  def bug_bounty_users_within_staging_env?
    Rails.env.staging? &&
      /-ywhadmin@yopmail.com$/.match?(email)
  end

  def authorization_definition_roles_as(kind)
    roles_for(kind).authorization_definitions
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
    Arel.sql <<~SQL.squish
      COALESCE(
        array_to_string(
          ARRAY(
            SELECT split_part(elem, ':', 1)
            FROM unnest(users.roles) AS elem
          ),
          ','
        ),
        ''
      )
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
