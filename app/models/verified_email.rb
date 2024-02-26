class VerifiedEmail < ApplicationRecord
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, presence: true, inclusion: { in: %w[unknown deliverable undeliverable risky] }

  def reacheable?
    %w[deliverable risky].include?(status)
  end

  def unreachable?
    status == 'undeliverable'
  end

  def unknown?
    status == 'unknown'
  end

  def determined?
    !unknown?
  end

  def recent?
    verified_at.present? &&
      verified_at > 30.days.ago
  end
end
