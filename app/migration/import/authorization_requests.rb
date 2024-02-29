class Import::AuthorizationRequests < Import::Base
  def initialize(options)
    super(options)
    @team_members = {}
  end

  def extract(enrollment_row)
    authorization_request = find_or_build_authorization_request(enrollment_row)

    user = fetch_applicant(enrollment_row)

    authorization_request.applicant = user
    authorization_request.organization = fetch_organization(user, enrollment_row)

    authorization_request.form_uid = fetch_form(authorization_request).id
    authorization_request.state = enrollment_row['status']

    if !authorization_request.filling?
      authorization_request.assign_attributes(
        terms_of_service_accepted: true,
        data_protection_officer_informed: true,
      )
    end

    if authorization_request.state == 'validated'
      authorization_request.assign_attributes(
        last_validated_at: DateTime.now,
      )
    end

    handle_authorization_request_type_specific_fields(authorization_request, enrollment_row)

    begin
      authorization_request.save!
      @models << authorization_request
    rescue ActiveRecord::RecordInvalid => e
      log("DataPass: https://datapass.api.gouv.fr/#{enrollment_row['target_api'].gsub('_', '-')}/#{enrollment_row['id']}")
      log("Errors: #{authorization_request.errors.full_messages.join("\n")}")

      byebug
    end
  end

  private

  def find_team_member(kind, enrollment_id)
    fetch_team_members(enrollment_id).find { |team_member| team_member['type'] == kind }
  end

  def fetch_team_members(enrollment_id)
    @team_members.fetch(enrollment_id) do
      enrollment_team_members = filtered_team_members.select { |row| row['enrollment_id'] == enrollment_id }

      @team_members[enrollment_id] = enrollment_team_members

      enrollment_team_members
    end
  end

  def fetch_organization(user, enrollment_row)
    return if user.blank?

    organization = user.organizations.find do |organization|
      organization.siret == enrollment_row['siret']
    end

    return organization if organization.present?

    new_potential_siret = {
      # PM => DINUM
      '11000101300017' => '13002526500013',
      # Agence de la recherche fermée
      '13000250400020' => '13000250400038',
    }[enrollment_row['siret']]

    return if new_potential_siret.blank?

    user.organizations.find_by(siret: new_potential_siret)
  end

  def fetch_applicant(enrollment_row)
    demandeur = find_team_member('demandeur', enrollment_row['id'])

    user = User.find_by(email: demandeur['email'].try(:downcase))

    return user if user.present?

    try_to_create_user!(enrollment_row, demandeur)
  end

  def try_to_create_user!(enrollment_row, demandeur)
    return if demandeur.blank? || demandeur['email'].blank?

    user = User.new(
      demandeur.to_h.slice(
        'email',
        'given_name',
        'family_name',
        'phone_number',
      ).merge(
        'job_title' => demandeur['job'],
      )
    )

    organization = Organization.find_or_initialize_by(siret: enrollment_row['siret'])
    organization.assign_attributes(
      mon_compte_pro_payload: { siret: enrollment_row['siret'], manual_creation: true },
      last_mon_compte_pro_updated_at: DateTime.now,
    )
    begin
      organization.save!
    rescue ActiveRecord::RecordInvalid => e
      if e.record.errors.include?(:siret)
        raise Import::AuthorizationRequests::Base::SkipRow.new(:invalid_siret_for_unknown_user_and_organization, id: enrollment_row['id'], target_api: enrollment_row['target_api'])
      else
        raise
      end
    end

    user.organizations << organization
    user.current_organization = organization

    user.save!

    user
  end

  def fetch_form(authorization_request)
    if authorization_request.definition.available_forms.one?
      authorization_request.definition.available_forms.first
    else
      authorization_request.definition.available_forms.find do |form|
        form.id.underscore == authorization_request.class.name.demodulize.underscore
      end
    end
  end

  def handle_authorization_request_type_specific_fields(authorization_request, enrollment_row)
    Kernel.const_get(
      "Import::AuthorizationRequests::#{authorization_request.type.split('::')[-1]}Attributes"
    ).new(
      authorization_request,
      enrollment_row,
      fetch_team_members(enrollment_row['id']),
    ).perform
  end

  def import?(enrollment_row)
    !old_draft?(enrollment_row) &&
      !ignore?(enrollment_row['id']) &&
      from_target_api_to_type(enrollment_row).present?
  end

  def old_draft?(enrollment_row)
    enrollment_row['status'] == 'draft' &&
      DateTime.parse(enrollment_row['created_at']) < DateTime.new(2022, 1, 1)
  end

  def ignore?(enrollment_id)
    [
      # Draft ~3 mois, boîte fermée
      '54815',
    ].include?(enrollment_id)
  end

  def find_or_build_authorization_request(enrollment_row)
    AuthorizationRequest.find_by(id: enrollment_row['id']) ||
      AuthorizationRequest.const_get(from_target_api_to_type(enrollment_row)).new(id: enrollment_row['id'], type: "AuthorizationRequest::#{from_target_api_to_type(enrollment_row)}")
  end

  def from_target_api_to_type(enrollment)
    {
      'hubee_portail' => 'hubee_cert_dc',
      'api_entreprise' => 'api_entreprise',
      'api_particulier' => 'api_particulier',
    }[enrollment['target_api']].try(:classify)
  end

  def csv_to_loop
    @csv_to_loop ||= csv('enrollments').select { |row| import?(row) }
  end

  def filtered_team_members
    @filtered_team_members ||= begin
      enrollment_ids = csv_to_loop.pluck('id')

      csv('team_members').select { |row| enrollment_ids.include?(row['enrollment_id']) }
    end
  end
end
