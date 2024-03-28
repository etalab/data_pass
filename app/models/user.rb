class User < ApplicationRecord
  include InstructorSettings

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

  scope :instructor_for, lambda { |authorization_request_type|
    where("
      EXISTS (
        SELECT 1
        FROM unnest(roles) AS role
        WHERE role = ?
      )
    ", "#{authorization_request_type.underscore}:instructor")
  }

  add_instructor_boolean_settings :submit_notifications, :messages_notifications

  def full_name
    "#{family_name} #{given_name}"
  end

  def instructor?(authorization_request_type = nil)
    if authorization_request_type
      roles.include?("#{authorization_request_type}:instructor")
    else
      roles.any? { |role| role.end_with?(':instructor') }
    end
  end

  def admin?
    roles.include?('admin')
  end

  def authorization_definition_roles_as(kind)
    roles.select { |role| role.end_with?(":#{kind}") }.map do |role|
      AuthorizationDefinition.find(role.split(':').first)
    end
  end
end
