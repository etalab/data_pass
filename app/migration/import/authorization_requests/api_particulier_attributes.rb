class Import::AuthorizationRequests::APIParticulierAttributes < Import::AuthorizationRequests::Base
  def affect_data
    affect_scopes
    affect_attributes
    affect_contacts
    affect_form_uid

    cadre_juridique_present = affect_potential_legal_document

    return if authorization_request.filling? || authorization_request.archived?

    affect_duree_conservation_donnees_caractere_personnel_justification

    skip_row!(:cadre_juridique_manquant) unless cadre_juridique_present
    skip_row!(:duree_conservation_donnees_caractere_personne_manquante) if authorization_request.duree_conservation_donnees_caractere_personnel.blank?
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
    elsif %w[9 16 19].include?(enrollment_row['id'].to_s)
      authorization_request.cadre_juridique_url = 'https://particulier.api.gouv.fr/cgu'
      true
    else
      false
    end
  end

  def affect_duree_conservation_donnees_caractere_personnel_justification
    return unless authorization_request.duree_conservation_donnees_caractere_personnel > 36 && authorization_request.duree_conservation_donnees_caractere_personnel_justification.blank?

    authorization_request.duree_conservation_donnees_caractere_personnel_justification = 'Non renseigné'
  end

  def affect_form_uid
    form_uid = demarche_to_form_uid

    return if form_uid.blank?

    authorization_request.form_uid = form_uid
  end

  def demarche_to_form_uid
    case enrollment_row['demarche']
    when 'arpege-concerto'
      'api-particulier-arpege-concerto'
    when 'ccas-arpege'
      'api-particulier-ccas-arpege'
    when 'abelium'
      'api-particulier-abelium'
    when 'agora-plus'
      'api-particulier-agora-plus'
    when 'cantine-de-france'
      'api-particulier-cantine-de-france'
    when 'bl-enfance-berger-levrault-cnaf'
      'api-particulier-bl-enfance-berger-levrault'
    when 'civil-enfance-ciril-group'
      'api-particulier-civil-enfance-ciril-group'
    when 'docaposte-fast'
      'api-particulier-docaposte-fast'
    when 'odyssee-pandore'
      'api-particulier-odyssee-informatique-pandore'
    when 'technocarte'
      'api-particulier-technocarte-ile'
    when 'nfi-grc'
      'api-particulier-nfi'
    when 'city-family-mushroom-software-cnaf'
      'api-particulier-city-family-mushroom-software'
    when 'amiciel-malice'
      'api-particulier-amiciel-malice'
    when 'qiis'
      'api-particulier-qiis-eticket'
    when 'aiga'
      'api-particulier-aiga'
    when 'teamnet'
      'api-particulier-teamnet-axel'
    when 'jvs-parascol'
      'api-particulier-jvs-parascol'
    when '3d-ouest'
      'api-particulier-3d-ouest'
    when 'entrouvert-publik'
      'api-particulier-entrouvert-publik'
    when 'waigeo'
      'api-particulier-waigeo-myperischool'
    when 'ccas-Melissandre-afi'
      'api-particulier-ccas-melissandre-afi'
    when 'ccas-ArcheMC2'
      'api-particulier-ccas-arche-mc2'
    when 'Coexya'
      'api-particulier-coexya'
    when 'cosoluce-fluo'
      'api-particulier-cosoluce-fluo'
    when 'sigec-maelis'
      'api-particulier-sigec-maelis'
    end
  end

  def attributes_mapping
    {
      'intitule' => 'intitule',
      'description' => 'description',
      'fondement_juridique_title' => 'cadre_juridique_nature',
      'fondement_juridique_url' => 'cadre_juridique_url',
      'date_mise_en_production' => 'date_prevue_mise_en_production',
      'volumetrie_approximative' => 'volumetrie_approximative',
      'data_recipients' => 'destinataire_donnees_caractere_personnel',
      'data_retention_period' => 'duree_conservation_donnees_caractere_personnel',
      'data_retention_comment' => 'duree_conservation_donnees_caractere_personnel_justification',
    }
  end
end
