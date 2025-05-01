class Import::AuthorizationRequests::APICaptchEtatAttributes < Import::AuthorizationRequests::Base
  def affect_data
    affect_attributes
    affect_contacts
    affect_potential_maquette_projet
    affect_potential_legal_document

    clean_authorization_request_external_provider_id

    return if authorization_request.valid?

    authorization_request.cadre_juridique_url = nil if authorization_request.errors[:cadre_juridique_url].any?
  end

  private

  def clean_authorization_request_external_provider_id
    return unless authorization_request.external_provider_id.present?

    authorization_request.external_provider_id = authorization_request.external_provider_id.split('/')[-1]
  end

  def attributes_mapping
    {
      "intitule" => "intitule",
      "description" => "description",
      "fondement_juridique_title" => "cadre_juridique_nature",
      "fondement_juridique_url" => "cadre_juridique_url",
      "date_mise_en_production" => "date_prevue_mise_en_production",
      "volumetrie_approximative" => "volumetrie_approximative",
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
