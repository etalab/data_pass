class User < ApplicationRecord
  self.ignored_columns += %w[current_organization_id]

  include NotificationsSettings

  ROLES = %w[reporter instructor developer].freeze

  validates :email,
    presence: true,
    uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }

  before_save { email.downcase! }

  validates :external_id, uniqueness: true, allow_nil: true

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

  scope :instructor_for, lambda { |authorization_request_type|
    where("
      EXISTS (
        SELECT 1
        FROM unnest(roles) AS role
        WHERE role = ?
      )
    ", "#{authorization_request_type.underscore}:instructor")
  }

  scope :developer_for, lambda { |authorization_request_type|
    where("
      EXISTS (
        SELECT 1
        FROM unnest(roles) AS role
        WHERE role = ?
      )
    ", "#{authorization_request_type.underscore}:developer")
  }

  scope :reporter_for, lambda { |authorization_request_type|
    where(
      "EXISTS (
        SELECT 1
        FROM unnest(roles) AS role
        WHERE role in (?)
      )",
      [
        "#{authorization_request_type.underscore}:instructor",
        "#{authorization_request_type.underscore}:developer",
        "#{authorization_request_type.underscore}:reporter",
      ]
    )
  }

  scope :admin, lambda {
    where(
      "EXISTS (
        SELECT 1
        FROM unnest(roles) AS role
        WHERE role in (?)
      )",
      ['admin']
    )
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

  def full_name
    return email unless family_name.present? && given_name.present?

    formatted_given_name = given_name.gsub(/\b\w+/) { |word| word.downcase.capitalize }
    "#{family_name.upcase} #{formatted_given_name}"
  end

  def instructor?(authorization_request_type = nil)
    if authorization_request_type
      roles.include?("#{authorization_request_type}:instructor")
    else
      roles.any? { |role| role.end_with?(':instructor') }
    end
  end

  def reporter_roles
    (roles.select { |role|
      role.end_with?(':reporter')
    } + instructor_roles + developer_roles).uniq
  end

  def instructor_roles
    roles.select { |role| role.end_with?(':instructor') }
  end

  def developer_roles
    roles.select { |role| role.end_with?(':developer') }
  end

  def reporter?(authorization_request_type = nil)
    return true if admin?
    return true if instructor?(authorization_request_type)

    if authorization_request_type
      roles.include?("#{authorization_request_type}:reporter")
    else
      roles.any? { |role| role.end_with?(':reporter') }
    end
  end

  def developer?
    developer_roles.any?
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
    public_send(:"#{kind}_roles")
      .map { |role| AuthorizationDefinition.find(role.split(':').first) }
      .uniq(&:id)
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
    Arel.sql <<-SQL.squish
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

  def add_to_organization(organization, verified: false, identity_provider_uid: nil, identity_federator: nil, current: false)
    organizations_users.find_or_create_by(organization:).tap do |org_user|
      updates = {
        identity_provider_uid:,
        identity_federator:,
        verified:,
      }.compact
      org_user.update!(updates) if updates.any?
      org_user.set_as_current! if current
    end
  end
end
