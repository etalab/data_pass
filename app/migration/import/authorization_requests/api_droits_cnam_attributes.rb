class Import::AuthorizationRequests::APIDroitsCNAMAttributes < Import::AuthorizationRequests::DGFIPSandboxAttributes
  def affect_data
    affect_attributes
    affect_contacts
    affect_potential_legal_document
    affect_franceconnect_data
    affect_form_uid

    affect_duree_conservation_donnees_caractere_personnel_justification

    return if authorization_request.valid?

    skip_row!(:invalid_cadre_juridique) if authorization_request.errors[:cadre_juridique_url].any?
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

  def demarche_to_form_uid
    case enrollment_row['demarche']
    when 'organisme_complementaire'
      'api-droits-cnam-organisme-complementaire'
    when 'etablissement_de_soin'
      'api-droits-cnam-etablissement-de-soin'
    else
      'api-droits-cnam'
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

  def affect_franceconnect_data
    france_connect_authorization = AuthorizationRequest::FranceConnect.find_by(id: enrollment_row['previous_enrollment_id'])

    return unless france_connect_authorization

    authorization_request.france_connect_authorization_id = france_connect_authorization.latest_authorization.id.to_s
  end
end
