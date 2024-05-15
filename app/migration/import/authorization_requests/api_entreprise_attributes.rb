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
      contact_data = find_team_member_by_type(from_contact)

      contact_data['email'] = find_team_member_by_type('responsable_technique')['email'] if enrollment_row['id'] == '848' && to_contact == 'contact_metier'

      if %w[draft archived changes_requested].include?(authorization_request.state)
        affect_team_attributes(contact_data, to_contact)
      elsif team_member_incomplete?(contact_data)
        user = User.find_by(email: contact_data['email'])

        if user && !team_member_incomplete?(user)
          affect_team_attributes(user.attributes.slice(*AuthorizationRequest.contact_attributes), to_contact)
          next
        end

        if contact_data['email']
          others_team_members = database.execute('select * from team_members where email = ?', contact_data['email']).to_a.map do |row|
            JSON.parse(row[-1]).to_h
          end

          potential_valid_team_member = others_team_members.select do |data|
            %w[given_name family_name phone_number job].all? { |key| data[key].present? }
          end.max do |data|
            data['id'].to_i
          end

          if potential_valid_team_member
            potential_valid_team_member['job_title'] ||= potential_valid_team_member.delete('job')

            affect_team_attributes(potential_valid_team_member, to_contact)
            next
          end

          potential_team_member_with_family_name = others_team_members.select do |data|
            data['family_name'].present?
          end.max do |data|
            data['id'].to_i
          end

          if potential_team_member_with_family_name.present?
            potential_team_member_with_family_name['job_title'] = potential_team_member_with_family_name.delete('job')

            if potential_team_member_with_family_name['family_name'].present? && potential_team_member_with_family_name['family_name'].include?(' ')
              potential_team_member_with_family_name['family_name'], potential_team_member_with_family_name['given_name'] = potential_team_member_with_family_name['family_name'].split(' ', 2)
            else
              potential_team_member_with_family_name['given_name'] = 'Non renseigné'
            end

            if potential_team_member_with_family_name['job_title'].blank?
              potential_team_member_with_family_name['job_title'] = 'Non renseigné'
            end

            if potential_team_member_with_family_name['phone_number'].blank?
              potential_team_member_with_family_name['phone_number'] = 'Non renseigné'
            end

            if %w[given_name family_name phone_number job_title].all? { |key| potential_team_member_with_family_name[key].present? }
              affect_team_attributes(potential_team_member_with_family_name, to_contact)
              next
            end
          end

          if contact_data['email'].present?
            %w[given_name family_name phone_number job_title].each do |key|
              contact_data[key] = 'Non renseigné' if contact_data[key].blank?
            end

            affect_team_attributes(contact_data, to_contact)
            next
          end
        end

        byebug

        if recent_validated_enrollment_exists?
          skip_row!('incomplete_contact_data_with_new_enrollments')
        else
          skip_row!('incomplete_contact_data_without_new_enrollments')
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

  def affect_form_uid
    form_uid = demarche_to_form_uid

    return if form_uid.blank?

    authorization_request.form_uid = form_uid
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
    end
  end

  def affect_not_specified_to_duree_conservation
    return if authorization_request.duree_conservation_donnees_caractere_personnel.present?

    authorization_request.duree_conservation_donnees_caractere_personnel = 'Non renseigné'
  end

  def recent_validated_enrollment_exists?
    bool = database.execute('select id from enrollments where copied_from_enrollment_id = ? and status = "validated" limit 1;', enrollment_row['id']).any?
    database.close
    bool
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
