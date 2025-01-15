class Import::AuthorizationRequests::APIEntrepriseAttributes < Import::AuthorizationRequests::Base
  def affect_data
    affect_scopes
    affect_attributes
    affect_contacts
    affect_potential_legal_document
    affect_not_specified_to_duree_conservation
    affect_form_uid
  end

  def affect_contacts
    {
      'contact_metier' => 'contact_metier',
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

  def affect_not_specified_to_duree_conservation
    return if authorization_request.duree_conservation_donnees_caractere_personnel.present?

    authorization_request.duree_conservation_donnees_caractere_personnel = 'Non renseigné'
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
    ['destinataire_donnees_caractere_personnel']
  end
end
