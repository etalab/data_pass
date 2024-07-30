class AuthorizationRequestChangelog < ApplicationRecord
  belongs_to :authorization_request

  has_one :organization, through: :authorization_request

  has_many :events,
    class_name: 'AuthorizationRequestEvent',
    inverse_of: :entity,
    dependent: :destroy
end
