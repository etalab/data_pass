class InstructorDraftRequestDocument < ApplicationRecord
  belongs_to :instructor_draft_request, inverse_of: :documents

  has_many_attached :files

  validates :identifier, presence: true
end
