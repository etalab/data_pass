class InstructorModificationRequest < ApplicationRecord
  validates :reason, presence: true
  belongs_to :authorization_request

  has_many :events,
    class_name: 'AuthorizationRequestEvent',
    inverse_of: :entity,
    dependent: :destroy
end
