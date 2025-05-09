class User < ApplicationRecord
  include NotificationsSettings

  validates :email, presence: true, uniqueness: true
  before_save { email.downcase! }

  validates :external_id, uniqueness: true, allow_nil: true

  belongs_to :current_organization, class_name: 'Organization'

  has_and_belongs_to_many :organizations

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
    if family_name.present? && given_name.present?
      "#{family_name} #{given_name}"
    else
      email
    end
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
    public_send(:"#{kind}_roles").map do |role|
      AuthorizationDefinition.find(role.split(':').first)
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      family_name
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
end
