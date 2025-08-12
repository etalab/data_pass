class AuthorizationRequestInstructorDraftDocument < ApplicationRecord
  belongs_to :authorization_request_instructor_draft

  has_many_attached :files

  validates :identifier, presence: true
end
