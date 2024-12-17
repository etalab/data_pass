class InstructorDraftRequest < ApplicationRecord
  belongs_to :instructor,
    class_name: 'User'

  belongs_to :applicant,
    optional: true,
    class_name: 'User'

  belongs_to :organization,
    optional: true

  has_many :documents,
    class_name: 'InstructorDraftRequestDocument',
    inverse_of: :instructor_draft_request,
    dependent: :destroy

  validates :data,
    presence: true

  validate :instructor_for_authorization_request

  scope :claimed, -> { where(claimed: true) }

  def project_name
    data['intitule'] || "Projet ##{id}"
  end

  def definition
    @definition ||= AuthorizationDefinition.find(authorization_request_class.demodulize.underscore)
  end

  def request
    authorization_request_class.constantize.new(
      data:,
      form_uid:
    )
  end

  private

  def instructor_for_authorization_request
    return if instructor.instructor?(authorization_request_class.demodulize.underscore)

    errors.add(:instructor, :invalid)
  end
end
