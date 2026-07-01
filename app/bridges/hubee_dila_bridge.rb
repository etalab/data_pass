class HubEEDilaBridge < HubEEBaseBridge
  PROCESS_CODES = {
    etat_civil: 'EtatCivil',
    depot_dossier_pacs: 'depotDossierPACS',
    recensement_citoyen: 'recensementCitoyen',
    hebergement_tourisme: 'HebergementTourisme',
    je_change_de_coordonnees: 'JeChangeDeCoordonnees'
  }.freeze

  def on_approve
    organization_hubee_payload = find_or_create_organization

    update_subscriptions(organization_hubee_payload, authorization_request.scopes)
  end

  private

  def update_subscriptions(organization_hubee_payload, updated_scopes)
    new_scopes = updated_scopes - former_scopes

    new_scopes.each do |scope|
      create_and_store_subscription(organization_hubee_payload, scope)
    end
  end

  def create_and_store_subscription(organization_hubee_payload, scope)
    subscription_hubee_payload = hubee_api_client.create_subscription(subscription_body(organization_hubee_payload, process_code(scope)))
    store_external_provider_id(scope, subscription_hubee_payload['id'])
  rescue HubEEAPIClient::AlreadyExistsError
    recover_existing_subscription(scope)
  end

  def recover_existing_subscription(scope)
    existing_subscription = find_existing_subscription(scope)

    raise "HubEE subscription should exist but was not found during recovery for authorization_request ##{authorization_request.id} (scope: #{scope})" unless existing_subscription

    Sentry.capture_message(
      "HubEE subscription already exists for authorization_request ##{authorization_request.id} (scope: #{scope})",
      level: :warning,
      extra: { subscription_id: existing_subscription[:id], scope: }
    )

    store_external_provider_id(scope, existing_subscription[:id])
  end

  def find_existing_subscription(scope)
    hubee_api_client.find_subscriptions(datapassId: authorization_request.id)
      .find { |s| s[:processCode] == process_code(scope) }
  end

  def store_external_provider_id(scope, token)
    tokens = stored_tokens
    tokens[scope] = token
    authorization_request.update!(external_provider_id: tokens.to_json)
  end

  def process_code(scope)
    code = PROCESS_CODES[scope.to_sym]
    raise 'Process code not found' if code.blank?

    code
  end

  def stored_tokens
    JSON.parse(authorization_request.external_provider_id || '{}')
  end

  def former_scopes
    stored_tokens.keys
  end
end
