class Import::AuthorizationRequests::LeTaxiAttributes < Import::AuthorizationRequests::Base
  def affect_data
    affect_attributes
    affect_contacts
    affect_potential_maquette_projet
    affect_technical_team
  end

  private

  def affect_technical_team
    authorization_request.technical_team_type = {
      'software_company' => 'editor',
      'internal_team' => 'internal',
      'other' => 'other',
      nil => 'other',
      '' => 'other',
    }[enrollment_row['technical_team_type']]

    authorization_request.technical_team_value = enrollment_row['technical_team_value']

    return if %w[internal].include?(authorization_request.technical_team_type)

    authorization_request.technical_team_value = 'Non renseigné' if authorization_request.technical_team_value.blank?
  end

  def attributes_mapping
    {
      "intitule" => "intitule",
      "description" => "description",
      "date_mise_en_production" => "date_prevue_mise_en_production",
      "volumetrie_approximative" => "volumetrie_approximative",
      "data_recipients" => "destinataire_donnees_caractere_personnel",
      "data_retention_period" => "duree_conservation_donnees_caractere_personnel",
      "data_retention_comment" => "duree_conservation_donnees_caractere_personnel_justification",
    }
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

  def attributes_with_possible_null_values
    ['destinataire_donnees_caractere_personnel']
  end
end
