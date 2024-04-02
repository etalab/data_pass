class RevocationOfAuthorization < ApplicationRecord
  belongs_to :authorization_request
end
