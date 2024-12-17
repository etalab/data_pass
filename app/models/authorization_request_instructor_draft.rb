class AuthorizationRequestInstructorDraft < ApplicationRecord
  belongs_to :instructor,
    class_name: 'User'

  belongs_to :applicant,
    optional: true,
    class_name: 'User'

  belongs_to :organization,
    optional: true

  validates :data,
    presence: true

  validate :instructor_for_authorization_request

  def project_name
    data['intitule'] || "Projet ##{id}"
  end

  def definition
    @definition ||= AuthorizationDefinition.find(authorization_request_class.demodulize.underscore)
  end

  private

  def instructor_for_authorization_request
    return if instructor.instructor?(authorization_request_class.demodulize.underscore)

    errors.add(:instructor, :invalid)
  end
end
