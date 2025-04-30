class Import::AuthorizationRequests::APISFiPSandboxAttributes < Import::AuthorizationRequests::DGFIPSandboxAttributes
  def affect_data
    affect_scopes
    affect_attributes
    affect_contacts
    affect_potential_legal_document
    affect_potential_maquette_projet
    affect_potential_specific_requirements
    affect_form_uid
    handle_incompatible_scopes_error

    affect_duree_conservation_donnees_caractere_personnel_justification

    return if authorization_request.valid?

    skip_row!(:invalid_cadre_juridique) if authorization_request.errors[:cadre_juridique_url].any?
  end

  def demarche_to_form_uid
    case enrollment_row['demarche']
    when 'aides_sociales_facultatives'
      'api-sfip-aides-sociales-facultatives-sandbox'
    when 'cantine_scolaire'
      'api-sfip-cantine-scolaire-sandbox'
    when 'activites_periscolaires'
      'api-sfip-activites-periscolaires-sandbox'
    when 'place_creche'
      'api-sfip-place-creche-sandbox'
    when 'stationnement_residentiel', 'carte_stationnement'
      'api-sfip-stationnement-residentiel-sandbox'
    when 'carte_transport'
      'api-sfip-carte-transport-sandbox'
    when 'eligibilite_lep', 'migration_api_particulier'
      'api-sfip-sandbox'
    else
      'api-sfip-sandbox'
    end
  end

  def handle_incompatible_scopes_error
    return if authorization_request.valid?
    return unless authorization_request.errors[:scopes].any?

    skip_row!("invalid_scopes_in_status_#{authorization_request.state}")
  end

  def affect_contacts
    {
      'responsable_technique' => 'contact_technique',
      'responsable_traitement' => 'responsable_traitement',
      'delegue_protection_donnees' => 'delegue_protection_donnees',
    }.each do |from_contact, to_contact|
      affect_contact(from_contact, to_contact)
    end
  end

  def attributes_mapping
    {
      "intitule" => "intitule",
      "description" => "description",
      "fondement_juridique_title" => "cadre_juridique_nature",
      "fondement_juridique_url" => "cadre_juridique_url",
      "date_mise_en_production" => "date_prevue_mise_en_production",
      "data_recipients" => "destinataire_donnees_caractere_personnel",
      "data_retention_period" => "duree_conservation_donnees_caractere_personnel",
      "data_retention_comment" => "duree_conservation_donnees_caractere_personnel_justification",
    }
  end

  def attributes_with_possible_null_values
    ['destinataire_donnees_caractere_personnel']
  end
end
