class Import::AuthorizationRequests::APIParticulierAttributes < Import::AuthorizationRequests::Base
  def affect_data
    affect_scopes
    affect_attributes
    affect_contacts
    cadre_juridique_present = affect_potential_legal_document

    skip_row!(:cadre_juridique_manquant) unless cadre_juridique_present
    skip_row!(:duree_conservation_donnees_caractere_personne_manquante) if authorization_request.duree_conservation_donnees_caractere_personnel.blank?
    skip_row!(:justification_duree_conservation_manquante) if authorization_request.duree_conservation_donnees_caractere_personnel > 36 && authorization_request.duree_conservation_donnees_caractere_personnel_justification.blank?
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
    return true if authorization_request.cadre_juridique_url.present?

    row = csv('documents').find { |row| row['attachable_id'] == enrollment_row['id'] && row['type'] == 'Document::LegalBasis' }

    if row
      attach_file('cadre_juridique_document', row)
      true
    else
      false
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
end
