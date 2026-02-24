class RevocationOfAuthorization < ApplicationRecord
  include CommonInstructionModel

  belongs_to :authorization, optional: true
end
