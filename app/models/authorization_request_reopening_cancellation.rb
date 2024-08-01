class AuthorizationRequestReopeningCancellation < ApplicationRecord
  belongs_to :user
  belongs_to :request,
    class_name: 'AuthorizationRequest'

  validates :reason, presence: true, if: -> { from_instructor? && !from_applicant? }
  validate :user_is_applicant_or_instructor

  def from_instructor?
    request.present? &&
      user.present? &&
      user.instructor?(authorization_request_type_underscored)
  end

  def from_applicant?
    request.present? &&
      user.present? &&
      user == request.applicant
  end

  def authorization_request
    request
  end

  private

  def authorization_request_type_underscored
    request.type.underscore.split('/').last
  end

  def user_is_applicant_or_instructor
    return if from_instructor?
    return if user == request.applicant

    errors.add(:user, :invalid)
  end
end
