class InstructorModificationRequest < ApplicationRecord
  include CommonInstructionModel

  validates :reason, presence: true
end
