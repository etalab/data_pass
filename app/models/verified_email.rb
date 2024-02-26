class VerifiedEmail < ApplicationRecord
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, presence: true, inclusion: { in: %w[unknown deliverable undeliverable risky] }

  def reacheable?
    %w[deliverable risky].include?(status)
  end
end
