class Message < ApplicationRecord
  validates :body, presence: true

  belongs_to :from,
    class_name: 'User',
    optional: true

  has_many :events,
    class_name: 'AuthorizationRequestEvent',
    inverse_of: :entity,
    dependent: :destroy

  belongs_to :authorization_request

  scope :unread, -> { where(read_at: nil) }
  scope :from_users, ->(users) { where(from_id: Array(users).pluck(:id)) }

  def from_applicant?
    from_id == authorization_request.applicant_id
  end
end
