class AuthorizationRequest::HubEEDila < AuthorizationRequest
  validate :unique_scope_request, on: :create

  add_scopes(validation: {
    presence: true, if: -> { need_complete_validation?(:scopes) }
  })

  contact :administrateur_metier, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }

  private

  def unique_scope_request
    existing_requests = self.class.where.not(state: 'archived')
      .where(
        organization:,
        type: 'AuthorizationRequest::HubEEDila',
        state: %w[draft validated submitted changes_requested]
      )

    existing_scopes = existing_requests.map(&:scopes).flatten.uniq

    required_scopes = %w[etat_civil depot_dossier_pacs recensement_citoyen hebergement_tourisme je_change_de_coordonnees]

    return unless (required_scopes & existing_scopes) == required_scopes

    errors.add(:base, 'Une demande d‘habilitation avec les mêmes scopes existe déjà pour cette organisation.')
  end
end
