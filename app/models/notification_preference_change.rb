class NotificationPreferenceChange < ApplicationRecord
  KINDS = %w[submit messages].freeze
  SOURCES = %w[email_token].freeze

  belongs_to :user

  validates :kind, inclusion: { in: KINDS }
  validates :source, inclusion: { in: SOURCES }
end
