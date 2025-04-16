module Import::AuthorizationRequests::DGFIPProduction
  def migrate_from_sandbox_to_production!
    @authorization_request = AuthorizationRequest.find(enrollment_row['previous_enrollment_id'])

    json = Kredis.json "authorization_request_data_#{enrollment_row['previous_enrollment_id']}"
    json.value = @authorization_request.data

    ActiveRecord::Base.transaction do
      authorization_request.update!(type: "AuthorizationRequest::#{self.class.to_s.split('::')[-1].sub('Attributes', '')}", state: 'draft', id: enrollment_row['id'])

      Authorization.where(request_id: enrollment_row['previous_enrollment_id']).update_all(request_id: enrollment_row['id'])
    end

    attachments = ActiveStorage::Attachment.where(record_type: 'AuthorizationRequest', record_id: enrollment_row['previous_enrollment_id'])

    json = Kredis.json "authorization_request_attachments_#{enrollment_row['previous_enrollment_id']}"
    json.value = { 'ids' => attachments.pluck(:id) }

    attachments.update_all(record_id: enrollment_row['id'])

    @authorization_request = AuthorizationRequest.find(enrollment_row['id'])
  rescue ActiveRecord::RecordNotFound => e
    if e.id == enrollment_row['previous_enrollment_id']
      lookup_from_first_migrated_production!
    else
      skip_row!(:sandbox_missing)
    end
  end

  def lookup_from_first_migrated_production!
    @authorization_request.data = Kredis.json("authorization_request_data_#{enrollment_row['previous_enrollment_id']}").value
    attachments = ActiveStorage::Attachment.where(id: Kredis.json("authorization_request_attachments_#{enrollment_row['previous_enrollment_id']}").value['ids']).dup

    attachments.each do |attachment|
      attachment.record_id = @authorization_request.id
      attachment.save(validate: false)
    end
  end

  def affect_operational_acceptance
    authorization_request.operational_acceptance_done = additional_content['recette_fonctionnelle'] ? '1' : nil
  end

  def affect_safety_certification
    return unless authorization_request.respond_to?(:safety_certification_authority_name)

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
