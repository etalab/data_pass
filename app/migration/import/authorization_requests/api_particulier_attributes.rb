class Import::AuthorizationRequests::APIParticulierAttributes < Import::AuthorizationRequests::Base
  def affect_data
    skip_row!(:invalid_habilitation) if authorization_request.state == 'refused' && no_valid_organization?

    affect_scopes
    affect_attributes
    affect_contacts
    affect_potential_legal_document
  end

  def affect_contacts
    {
      'responsable_technique' => 'contact_technique',
      'responsable_traitement' => 'responsable_traitement',
      'delegue_protection_donnees' => 'delegue_protection_donnees',
    }.each do |from_contact, to_contact|
      contact_data = find_team_member_by_type(from_contact)

      if authorization_request.draft?
        affect_team_attributes(contact_data, to_contact)
      elsif team_member_incomplete?(contact_data)
        user = User.find_by(email: contact_data['email'])

        if user && !team_member_incomplete?(user)
          affect_team_attributes(user.attributes.slice(*AuthorizationRequest.contact_attributes), to_contact)
        else
          skip_row!("incomplete_#{from_contact}_contact_data".to_sym)
        end
      else
        affect_team_attributes(contact_data, to_contact)
      end
    end
  end

  def affect_potential_legal_document
    return if authorization_request.cadre_juridique_url.present?

    row = csv('documents').find { |row| row['attachable_id'] == enrollment_row['id'] && row['type'] == 'Document::LegalBasis' }

    if row
      attach_file('cadre_juridique_document', row)
    end
  end

  def no_valid_organization?

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
end
