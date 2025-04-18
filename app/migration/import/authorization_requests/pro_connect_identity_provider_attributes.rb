class Import::AuthorizationRequests::ProConnectIdentityProviderAttributes < Import::AuthorizationRequests::Base
  def affect_data
    affect_attributes
    affect_scopes
    affect_modalities
    affect_contacts
    affect_potential_legal_document
    affect_duree_conservation_donnees_caractere_personnel_justification

    return if authorization_request.valid?

    skip_row!(:invalid_cadre_juridique) if authorization_request.errors[:cadre_juridique_url].any?
  end

  def affect_modalities
    authorization_request.modalities ||= []

    {
      'acces_rie' => 'rie',
      'acces_internet' => 'internet',
    }.each do |from, to|
      next unless additional_content[from]

      authorization_request.modalities = authorization_request.modalities.concat([to])
    end

    authorization_request.modalities = authorization_request.modalities.uniq

    return if authorization_request.modalities.present?
    return if %w[refused validated].exclude?(authorization_request.state)

    skip_row!("no_modalities_in_status_#{authorization_request.state}")
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
