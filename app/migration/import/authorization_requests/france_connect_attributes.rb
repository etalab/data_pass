class Import::AuthorizationRequests::FranceConnectAttributes < Import::AuthorizationRequests::Base
  def affect_data
    affect_scopes
    affect_attributes
    affect_contacts
    affect_potential_legal_document
    affect_form_uid
    authorization_request.france_connect_eidas = extract_eidas

    return if authorization_request.valid?

    skip_row!(:invalid_cadre_juridique) if authorization_request.errors[:cadre_juridique_url].any?
    skip_row!(:no_scopes) if authorization_request.scopes.blank?
    skip_row!(:no_destinataire_donnees_caractere_personnel) if authorization_request.destinataire_donnees_caractere_personnel.blank?
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

  def affect_potential_legal_document
    return if authorization_request.cadre_juridique_url.present?

    row = csv('documents').find { |row| row['attachable_id'] == enrollment_row['id'] && row['type'] == 'Document::LegalBasis' }

    if row
      attach_file('cadre_juridique_document', row)
    end
  end

  def extract_eidas
    case additional_content['eidas_level']
    when '2'
      'eidas_2'
    else
      'eidas_1'
    end
  end

  def demarche_to_form_uid
    case enrollment_row['demarche']
    when 'collectivite'
      'france-connect-collectivite-administration'
    when 'epermis'
      'france-connect-collectivite-epermis'
    when 'sns'
      'france-connect-sante'
    else
      'france-connect'
    end
  end

  def attributes_mapping
    {
      "intitule" => "intitule",
      "description" => "description",
      "fondement_juridique_title" => "cadre_juridique_nature",
      "fondement_juridique_url" => "cadre_juridique_url",
      "date_mise_en_production" => "date_prevue_mise_en_production",
      "volumetrie_approximative" => "volumetrie_approximative",
      "data_recipients" => "destinataire_donnees_caractere_personnel",
      "data_retention_period" => "duree_conservation_donnees_caractere_personnel",
      "data_retention_comment" => "duree_conservation_donnees_caractere_personnel_justification",
    }
  end

  def attributes_with_possible_null_values
    ['duree_conservation_donnees_caractere_personnel_justification']
  end
end
