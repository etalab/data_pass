class DenialOfAuthorization < ApplicationRecord
  include CommonInstructionModel

  validates :reason, presence: true
end
