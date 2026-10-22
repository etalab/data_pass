class AuthorizationRequest::HubEECertDC < AuthorizationRequest
  validate :no_other_active_request_of_this_type, on: :create

  contact :administrateur_metier, validation_condition: ->(record) { record.need_complete_validation? }, options: { required_personal_email: true }

  validates :administrateur_metier_phone_number, french_phone_number: true, if: ->(record) { record.need_complete_validation? }

  private

  def no_other_active_request_of_this_type
    return unless AuthorizationRequestCreationRules.for_request_class(self.class, organization:).unicity_violated?

    errors.add(:base, :already_exists)
  end
end
