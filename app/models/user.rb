class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  before_save { email.downcase! }

  validates :external_id, presence: true, uniqueness: true

  belongs_to :current_organization, class_name: 'Organization'

  has_and_belongs_to_many :organizations

  has_many :authorization_requests_as_applicant,
    dependent: :restrict_with_exception,
    class_name: 'AuthorizationRequest',
    inverse_of: :applicant

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
end
