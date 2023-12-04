class AuthorizationRequest < ApplicationRecord
  belongs_to :applicant,
    class_name: 'User',
    inverse_of: :authorization_requests

  belongs_to :organization

  def form_model
    @form_model ||= AuthorizationRequestForm.where(authorization_request_class: self.class).first
  end

  validate :applicant_belongs_to_organization

  def applicant_belongs_to_organization
    return unless applicant.organizations.exclude?(organization)

    errors.add(:applicant, :belongs_to)
  end
end
