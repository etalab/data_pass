class Authorization < ApplicationRecord
  validates :data, presence: true

  belongs_to :applicant,
    class_name: 'User',
    inverse_of: :authorizations_as_applicant

  belongs_to :authorization_request

  has_one :organization,
    through: :authorization_request
end
