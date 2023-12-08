class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  before_save { email.downcase! }

  validates :external_id, presence: true, uniqueness: true

  belongs_to :current_organization, class_name: 'Organization'

  has_and_belongs_to_many :organizations

  has_many :authorization_requests,
    dependent: :restrict_with_exception,
    inverse_of: :applicant

  def full_name
    "#{family_name} #{given_name}"
  end
end
