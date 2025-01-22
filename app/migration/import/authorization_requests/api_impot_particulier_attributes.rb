class Import::AuthorizationRequests::APIImpotParticulierAttributes < Import::AuthorizationRequests::APIImpotParticulierSandboxAttributes
  def affect_data
    migrate_from_sandbox_to_production!

    affect_form_uid

    affect_operational_acceptance
    affect_safety_certification
    affect_volumetrie

    handle_franceconnect

    authorization_request.state = enrollment_row['status']

    return if authorization_request.valid?

    skip_row!(:invalid_cadre_juridique) if authorization_request.errors[:cadre_juridique_url].any?
  end

  private

  def migrate_from_sandbox_to_production!
    @authorization_request = AuthorizationRequest.find(enrollment_row['previous_enrollment_id'])

    authorization_request.update!(type: 'AuthorizationRequest::APIImpotParticulier', state: 'draft', id: enrollment_row['id'])

    ActiveStorage::Attachment.where(record_type: 'AuthorizationRequest', record_id: enrollment_row['previous_enrollment_id']).update_all(record_id: enrollment_row['id'])

    @authorization_request = AuthorizationRequest.find(enrollment_row['id'])
  rescue ActiveRecord::RecordNotFound
    skip_row!(:sandbox_missing)
  end

  def handle_franceconnect
    return unless enrollment_row['target_api'] == 'api_impot_particulier_fc_production'

    authorization_request.modalities ||= []
    authorization_request.modalities << 'with_france_connect'
    authorization_request.modalities = authorization_request.modalities.uniq
  end

  # FIXME
  def affect_form_uid
    authorization_request.form_uid = authorization_request.definition.available_forms.first.id
  end

  def affect_operational_acceptance
    authorization_request.operational_acceptance_done = additional_content['recette_fonctionnelle'] ? '1' : nil
  end

  def affect_safety_certification
    {
      'autorite_homologation_nom' => 'safety_certification_authority_name',
      'autorite_homologation_fonction' => 'safety_certification_authority_function',
      'date_homologation' => 'safety_certification_begin_date',
      'date_fin_homologation' => 'safety_certification_end_date'
    }.each do |from, to|
      authorization_request.public_send("#{to}=", additional_content[from])
    end

    affect_potential_document('Document::DecisionHomologation', 'safety_certification_document')

    return if authorization_request.safety_certification_begin_date.blank? || authorization_request.safety_certification_end_date.blank?

    begin
      return unless Date.parse(authorization_request.safety_certification_begin_date) == Date.parse(authorization_request.safety_certification_end_date)
    rescue TypeError
      return
    end

    authorization_request.safety_certification_end_date = (Date.parse(authorization_request.safety_certification_begin_date) + 1.day).to_s
  end

  def affect_volumetrie
    authorization_request.volumetrie_appels_par_minute = additional_content['volumetrie_appels_par_minute'].try(:to_i)

    return if authorization_request.volumetrie_appels_par_minute == 50

    authorization_request.volumetrie_justification = 'Non renseignée'
  end
end
