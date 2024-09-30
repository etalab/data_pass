class AuthorizationRequest::HubEECertDC < AuthorizationRequest
  validate :only_one_authorization_of_this_type_exists, on: :create

  contact :administrateur_metier, validation_condition: ->(record) { record.need_complete_validation? }, options: { required_personal_email: true }

  private

  def only_one_authorization_of_this_type_exists
    return unless another_authorization_of_this_type_exists?

    errors.add(:base, :already_exists)
  end

  def another_authorization_of_this_type_exists?
    self.class
      .where(organization:, type:)
      .where.not(state: 'archived')
      .exists?
  end
end
