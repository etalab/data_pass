class CreateDiffFromEvent
  include LocalDatabaseUtils
  include UserLegacyUtils

  attr_reader :event_row, :authorization_request

  def initialize(event_row, authorization_request, relevant_rows: nil)
    @event_row = event_row
    @authorization_request = authorization_request

    if relevant_rows.present?
      @relevant_rows = relevant_rows
    else
      fetch_relevant_rows!
    end
  end

  def perform
    return {} if @relevant_rows.empty?

    final_diff = {}

    @relevant_rows.each do |row|
      event_diff = JSON.parse(row['diff'] || '{}')

      case event_diff['_v']
      when '2'
        handle_v2(final_diff, event_diff)
      when '3'
        handle_v3(final_diff, event_diff)
      else
        raise "Invalid version #{event_diff['_v']}" if event_diff['_v'].present?

        handle_v1(final_diff, event_diff)
      end
    end

    final_diff.delete_if do |_,changes|
      changes.uniq.count == 1
    end

    final_diff
  rescue => e
    byebug
  ensure
    database.close
  end

  private

  def handle_v1(final_diff, event_diff)
    clean_keys(
      event_diff,
      [
        '_v',
        'dpo_id',
        'siret',
        'organization_id',
        'zip_code',
        'nom_raison_sociale',
        'responsable_traitement_id',
        'technical_team_type',
        'technical_team_value',
        'demarche',
        'updated_at',
        'nom_application_metier',
        'nom_editeur',
        'numero_version',
        'ips_de_production',
        'nombre_demandes_mensuelles',
        'nombre_demandes_annuelle',
        'pic_demandes_par_heure',
        'eidas_1',
        'eidas_2',
        'eidas_level',
        'utilisation_franceconnect_autre_projet',
        'date_integration',
        'code_ic',
        'type_de_depenses',
        'previous_enrollment_id',
        'acces_spi',
        'acces_etat_civil',
      ]
    )

    handle_user_change(final_diff, event_diff)

    {
      'dpo' => 'delegue_protection_donnees',
      'responsable_traitement' => 'responsable_traitement',
    }.each do |old_contact_kind, new_contact_kind|
      {
        'family_name' => 'family_name',
        'given_name' => 'given_name',
        'label' => 'family_name',
        'email' => 'email',
        'phone_number' => 'phone_number',
        'job' => 'job_title',
      }.each do |old_attribute, new_attribute|
        value = event_diff.delete("#{old_contact_kind}_#{old_attribute}")

        next if value.nil?

        final_diff["#{new_contact_kind}_#{new_attribute}"] = value.map { |v| sanitize_data(v) }
      end
    end

    attributes_mapping.each do |old_attribute, new_attribute|
      value = event_diff.delete(old_attribute)

      next unless authorization_request.class.extra_attributes.include?(new_attribute.to_sym)
      next if value.nil?

      if value.is_a?(Array)
        final_diff[new_attribute] = value.map { |v| sanitize_data(v) }
      else
        final_diff[new_attribute] = [nil, value]
      end
    end

    if event_diff['contacts']
      from, to = event_diff.delete('contacts')

      {
        'dpo' => 'delegue_protection_donnees',
        'responsable_traitement' => 'responsable_traitement',
        'metier' => 'contact_metier',
        'technique' => 'contact_technique',
      }.each do |old_contact_kind, new_contact_kind|
        next if from.nil?

        valid_from_contact = from.find { |contact| contact['id'] == old_contact_kind }

        next unless valid_from_contact.present?
        next unless authorization_request.class.contact_types.include?(new_contact_kind.to_sym)

        valid_to_contact = to.find { |contact| contact['id'] == old_contact_kind }

        {
          'family_name' => 'family_name',
          'nom' => 'family_name',
          'given_name' => 'given_name',
          'email' => 'email',
          'phone_number' => 'phone_number',
          'job' => 'job_title',
        }.each do |old_attribute, new_attribute|
          next if valid_from_contact[old_attribute].nil?

          from_value = sanitize_data(valid_from_contact[old_attribute])
          to_value = sanitize_data(valid_to_contact[old_attribute])

          next if from_value == to_value

          final_diff["#{new_contact_kind}_#{new_attribute}"] ||= [sanitize_data(valid_from_contact[old_attribute]), sanitize_data(valid_to_contact[old_attribute])]
        end
      end
    end

    if scopes = event_diff.delete('scopes')
      from = final_diff['scopes'].present? ? final_diff['scopes'].first : scopes[0].select { |k,v| v == true }.keys

      final_diff['scopes'] = [
        from,
        scopes[1].select { |k,v| v == true }.keys
      ]

      final_diff.delete('scopes') if final_diff['scopes'].first == final_diff['scopes'].last
    end

    byebug if event_diff.keys.present?
    byebug if final_diff.any? { |k,v| !v.is_a?(Array) || v.size != 2 }
  end

  def handle_v2_v3(final_diff, event_diff, handle_scopes:)
    clean_keys(
      event_diff,
      [
        '_v',
        'siret',
        'organization_id',
        'nom_raison_sociale',
        'zip_code',
        'technical_team_type',
        'technical_team_value',
        'demarche',
        'ips_de_production',
        'nombre_demandes_mensuelles',
        'nombre_demandes_annuelle',
        'pic_demandes_par_heure',
        'eidas_1',
        'eidas_2',
        'eidas_level',
        'utilisation_franceconnect_autre_projet',
        'date_integration',
        'code_ic',
        'type_de_depenses',
        'previous_enrollment_id',
        'acces_spi',
        'acces_etat_civil',
      ]
    )

    handle_user_change(final_diff, event_diff)

    attributes_mapping.each do |old_attribute, new_attribute|
      value = event_diff.delete(old_attribute)

      next unless authorization_request.class.extra_attributes.include?(new_attribute.to_sym)
      next if value.nil?

      if value.size == 1
        value = [nil, value.first]
      end

      final_diff[new_attribute] = value.map { |v| sanitize_data(v) }
    end

    team_members_diff = event_diff.delete('team_members')

    if team_members_diff
      team_members = retrieve_team_members_from_database.sort_by { |tm| tm['id'] }

      team_members_diff.delete('_t')
      team_members_diff.each do |index, team_member_diff|
        if team_member_diff['type'].present?
          team_member_diff_type = Array(team_member_diff['type'])[0]
          team_member = team_members.find { |tm| tm['type'] == team_member_diff_type }
        else
          team_member = team_members[index.to_i]
        end

        byebug if team_member.nil?
        next if team_member['type'] == 'demandeur' || team_member_ids_is_demandeur?(team_member['id'])

        final_type = {
          'metier' => 'contact_metier',
          'contact_metier' => 'contact_metier',
          'technique' => 'contact_technique',
          'contact_technique' => 'contact_technique',
          'responsable_technique' => 'contact_technique',
          'dpo' => 'delegue_protection_donnees',
          'delegue_protection_donnees' => 'delegue_protection_donnees',
          'responsable_traitement' => 'responsable_traitement',
          'responsable_metier' => 'administrateur_metier',
        }[team_member['type']]

        byebug if final_type.nil?

        next if team_member.blank?

        {
          'family_name' => 'family_name',
          'given_name' => 'given_name',
          'email' => 'email',
          'phone_number' => 'phone_number',
          'job' => 'job_title',
        }.each do |old_attribute, new_attribute|
          value = team_member_diff.delete(old_attribute)

          next if value.nil?

          if value.size == 1
            value = [nil, value.first]
          end
          byebug if value.is_a?(String)

          final_diff["#{final_type}_#{new_attribute}"] = value.map { |v| sanitize_data(v) }
        end

        %w[
          id
          user_id
          type
          enrollment_id
        ].each do |attribute|
          team_member_diff.delete(attribute)
        end

        byebug if team_member_diff.keys.present?
      end
    end

    scopes = event_diff.delete('scopes')

    if handle_scopes && scopes
      from = final_diff['scopes'].present? ? final_diff['scopes'].first : scopes[0]

      final_diff['scopes'] = [
        from,
        scopes[1],
      ]

      final_diff.delete('scopes') if final_diff['scopes'].first == final_diff['scopes'].last
    end

    documents = event_diff.delete('documents')
    if documents
      documents.delete('_t')

      documents.each do |_, document_diff|
        case document_diff['type'][0]
        when 'Document::MaquetteProjet'
          final_diff['maquette_projet'] = [nil, document_diff['attachment'][0]]
        when 'Document::LegalBasis'
          final_diff['cadre_juridique_document'] = [nil, document_diff['attachment'][0]]
        when 'Document::AttestationFiscale'
          final_diff['attestation_fiscale'] = [nil, document_diff['attachment'][0]]
        when 'Document::ExpressionBesoinSpecifique'
          final_diff['specific_requirements_document'] = [nil, document_diff['attachment'][0]]
        when 'Document::DecisionHomologation'
          final_diff['safety_certification_document'] = [nil, document_diff['attachment'][0]]
        else
          byebug
        end
      end
    end

    byebug if event_diff.keys.present?
    byebug if final_diff.any? { |k,v| !v.is_a?(Array) || v.size != 2 }
  end

  def handle_v2(final_diff, event_diff)
    handle_v2_v3(final_diff, event_diff, handle_scopes: false)
  end

  def handle_v3(final_diff, event_diff)
    handle_v2_v3(final_diff, event_diff, handle_scopes: true)
  end

  def attributes_mapping
    {
      'intitule' => 'intitule',
      'description' => 'description',
      'fondement_juridique_url' => 'cadre_juridique_url',
      'fondement_juridique_title' => 'cadre_juridique_nature',
      'date_mise_en_production' => 'date_prevue_mise_en_production',
      "volumetrie_approximative" => "volumetrie_approximative",
      'data_recipients' => 'destinataire_donnees_caractere_personnel',
      'data_retention_period' => 'duree_conservation_donnees_caractere_personnel',
      'data_retention_comment' => 'duree_conservation_donnees_caractere_personnel_justification',
      'production_date' => 'date_prevue_mise_en_production',
      'autorite_homologation_nom' => 'safety_certification_authority_name',
      'autorite_homologation_fonction' => 'safety_certification_authority_function',
      'date_homologation' => 'safety_certification_begin_date',
      'date_fin_homologation' => 'safety_certification_end_date',
      'volumetrie_appels_par_minute' => 'volumetrie_appels_par_minute'
    }
  end

  def clean_keys(event_diff, keys)
    keys = keys.concat(checkbox_keys)

    event_diff['additional_content'] = [event_diff['additional_content']] if event_diff['additional_content'].is_a?(Hash)

    additional_content_keys = (event_diff['additional_content'] || []).map { |ac| ac.keys }.flatten.uniq

    additional_content_keys.each do |key|
      byebug if event_diff[key].present?
    end

    (event_diff['additional_content'] || []).each do |data|
      data.each do |key, value|
        event_diff[key] = value
      end
    end

    event_diff.delete('additional_content')

    event_diff.delete_if { |key, _| key.to_s.start_with?('acces_') }

    keys.each do |key|
      event_diff.delete(key)
    end
  end

  def handle_user_change(final_diff, event_diff)
    return unless event_diff['user_id']

    final_diff['applicant_id'] = event_diff.delete('user_id').map { |legacy_user_id| legacy_user_id_to_user_id(legacy_user_id) }

    byebug if final_diff['applicant_id'].any? { |v| v.nil? }
  end

  def fetch_relevant_rows!
    all_events = database.execute('select * from events where authorization_request_id = ? order by created_at desc', event_row['enrollment_id']).map do |row|
      JSON.parse(row[-1]).to_h
    end

    all_events_before_this_submit = all_events.select do |event|
      DateTime.parse(event['created_at']) <= DateTime.parse(event_row['created_at'])
    end

    if all_events_before_this_submit[1..].index { |event| event['name'] == 'submit' }.nil?
      @relevant_rows = all_events_before_this_submit[1..]
    else
      @relevant_rows = all_events_before_this_submit[1..all_events_before_this_submit[1..].index { |event| event['name'] == 'submit' }]
    end

    @relevant_rows.select! do |row|
      row['name'] == 'update' &&
        row['diff'] != '{}'
    end

    @relevant_rows.reverse!
  end

  def retrieve_team_members_from_database
    @retrieve_team_members_from_database ||= database.execute('select * from team_members where authorization_request_id = ?', event_row['enrollment_id']).map do |row|
      JSON.parse(row[-1]).to_h
    end
  end

  def sanitize_data(datum)
    if datum.blank?
      nil
    else
      begin
        datum.strip
      rescue
        datum
      end
    end
  end

  def team_member_ids_is_demandeur?(team_member_id)
    %w[
      206985
    ].include?(team_member_id)
  end

  def checkbox_keys
    %w[
      has_alternative_authentication_methods
      rgpd_general_agreement
      cgu_approved
      dpo_is_informed
      recette_fonctionnelle
    ]
  end
end
