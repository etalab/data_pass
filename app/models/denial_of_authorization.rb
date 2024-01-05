class DenialOfAuthorization < ApplicationRecord
  validates :reason, presence: true
  belongs_to :authorization_request
end
