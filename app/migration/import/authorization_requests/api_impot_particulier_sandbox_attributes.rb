class Import::AuthorizationRequests::APIImpotParticulierSandboxAttributes < Import::AuthorizationRequests::Base
  def affect_data
    affect_scopes
    affect_attributes
    affect_contacts
    affect_potential_legal_document
    affect_potential_specific_requirements
    affect_modalities
    # affect_form_uid
    handle_incompatible_scopes_error

    affect_duree_conservation_donnees_caractere_personnel_justification

    return if authorization_request.valid?

    skip_row!(:invalid_cadre_juridique) if authorization_request.errors[:cadre_juridique_url].any?
  end

  def handle_incompatible_scopes_error
    return if authorization_request.valid?
    return unless authorization_request.errors[:scopes].any?

    skip_row!("invalid_scopes_in_status_#{authorization_request.state}")
  end

  def affect_potential_specific_requirements
    return unless affect_potential_document('Document::ExpressionBesoinSpecifique', 'specific_requirements_document')

    authorization_request.specific_requirements = '1'
  end

  def affect_modalities
    authorization_request.modalities ||= []

    {
      'acces_spi' => 'with_spi',
      'acces_etat_civil' => 'with_etat_civil'
    }.each do |from, to|
      next unless additional_content[from]

      authorization_request.modalities = authorization_request.modalities.concat([to])
    end

    affect_franceconnect_data if with_franceconnect?

    authorization_request.modalities = authorization_request.modalities.uniq

    return if authorization_request.modalities.present?
    return if %w[refused validated].exclude?(authorization_request.state)

    skip_row!("no_modalities_in_status_#{authorization_request.state}")
  end

  def with_franceconnect?
    return unless enrollment_row['previous_enrollment_id'].present?

    authorization_request.modalities << 'with_france_connect'
  end

  def affect_franceconnect_data
    authorization_request.france_connect_authorization_id = enrollment_row['previous_enrollment_id']
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

  # FIXME check https://metabase.entreprise.api.gouv.fr/dashboard/50-datapass-exploration?nom_de_l%27api_(target_api)=api_impot_particulier_sandbox
  def demarche_to_form_uid
    case enrollment_row['demarche']
    when 'marches_publics'
      'api-entreprise-marches-publics'
    when 'aides_publiques'
      'api-entreprise-aides-publiques'
    when 'subventions_associations'
      'api-entreprise-subventions-associations'
    when 'portail_gru'
      'api-entreprise-portail-gru-preremplissage'
    when 'portail_gru_instruction'
      'api-entreprise-portail-gru-instruction'
    when 'detection_fraude'
      'api-entreprise-detection-fraude'
    when 'e_attestations'
      'api-entreprise-e-attestations'
    when 'provigis'
      'api-entreprise-provigis'
    when 'achat_solution'
      'api-entreprise-achat-solution'
    when 'atexo'
      'api-entreprise-atexo'
    when 'mgdis'
      'api-entreprise-mgdis'
    when 'setec'
      'api-entreprise-setec-atexo'
    when 'editeur'
      'api-entreprise-editeur'
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
