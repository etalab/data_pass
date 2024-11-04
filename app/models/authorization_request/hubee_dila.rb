class AuthorizationRequest::HubEEDila < AuthorizationRequest
  validate :scopes_not_already_selected_in_another_organization_authorization_request, on: :create

  add_scopes(validation: {
    presence: true, if: -> { need_complete_validation?(:scopes) }
  })

  contact :administrateur_metier, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }, options: { required_personal_email: true }

  private

  def scopes_not_already_selected_in_another_organization_authorization_request
    existing_requests = self.class
      .where.not(state: 'archived')
      .where(
        organization:,
        type: 'AuthorizationRequest::HubEEDila',
      ).with_scopes_intersecting(scopes)

    return unless existing_requests.any?

    errors.add(:scopes, 'ont déjà été sélectionnés pour une autre demande d\'habilitation de l\'organisation')
  end
end
