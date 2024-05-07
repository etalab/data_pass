module CommonAuthorizationModelsPolicies
  def new?
    !unicity_constraint_violated? && !hubee_scope_uniqueness_constraint? &&
      record.startable_by_applicant
  end

  def create?
    new?
  end

  protected

  def authorization_request_class
    fail NoImplementedError
  end

  private

  def unicity_constraint_violated?
    return false unless hubee_cert_dc?

    another_authorization_request_with_same_type_exists?
  end

  def another_authorization_request_with_same_type_exists?
    current_organization && current_organization.active_authorization_requests.where(type: authorization_request_class).any?
  end

  def hubee_scope_uniqueness_constraint?
    return false unless hubee_dila?

    requested_scopes?
  end

  def requested_scopes?
    existing_requests = current_organization.active_authorization_requests.where(type: authorization_request_class, state: %w[validated submitted changes_requested])

    return false unless current_organization && existing_requests.any?

    existing_scopes = existing_requests.map(&:scopes).flatten.uniq
    required_scopes = %w[etat_civil depot_dossier_pacs recensement_citoyen hebergement_tourisme je_change_de_coordonnees]

    required_scopes.intersect?(existing_scopes)
  end

  def hubee_cert_dc?
    authorization_request_class == 'AuthorizationRequest::HubEECertDC'
  end

  def hubee_dila?
    authorization_request_class == 'AuthorizationRequest::HubEEDila'
  end
end
