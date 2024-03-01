class Message < ApplicationRecord
  validates :body, presence: true

  belongs_to :from,
    class_name: 'User',
    optional: true

  belongs_to :authorization_request

  scope :unread, -> { where(read_at: nil) }
  scope :from_users, ->(users) { where(from_id: Array(users).pluck(:id)) }
end
