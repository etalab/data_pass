class WebhookAttempt < ApplicationRecord
  SUCCESS_STATUS_CODES = [200, 201, 204].freeze

  belongs_to :webhook,
    inverse_of: :attempts

  belongs_to :authorization_request

  scope :recent, -> { order(created_at: :desc) }
  scope :failed, -> { where.not(status_code: SUCCESS_STATUS_CODES).or(where(status_code: nil)) }
  scope :successful, -> { where(status_code: SUCCESS_STATUS_CODES) }
  scope :between_dates, ->(start_date, end_date) { where(created_at: start_date..end_date) }
  scope :latest, ->(limit = 100) { recent.limit(limit) }

  def success?
    SUCCESS_STATUS_CODES.include?(status_code)
  end
end
