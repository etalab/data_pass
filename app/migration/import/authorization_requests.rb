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

    if !authorization_request.in_draft?
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

    unless authorization_request.valid?
      log("Errors: #{authorization_request.errors.full_messages}\n")

      byebug
    end

    authorization_request.save!

    @models << authorization_request
  rescue Import::AuthorizationRequests::Base::SkipRow => e
    case e.kind
    when :missing_applicant
      log("Skipping enrollment #{enrollment_row['id']} because applicant is missing\n")
    end

    raise
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

    user.organizations.find do |organization|
      organization.mon_compte_pro_payload['id'].to_s == enrollment_row['organization_id'].to_s
    end || (raise "No organization found for #{enrollment_row['organization_id']} (enrollment ##{enrollment_row['id']})}")
  end

  def fetch_applicant(enrollment_row)
    demandeur = find_team_member('demandeur', enrollment_row['id'])

    User.find_by(email: demandeur['email'])
  end

  def fetch_form(authorization_request)
    if authorization_request.definition.available_forms.one?
      authorization_request.definition.available_forms.first
    else
      authorization_request.definition.available_forms.find do |form|
        form.id.underscore == authorization_request.class.name.underscore
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
    from_target_api_to_type(enrollment_row).present?
  end

  def find_or_build_authorization_request(enrollment_row)
    AuthorizationRequest.find_by(id: enrollment_row['id']) ||
      AuthorizationRequest.const_get(from_target_api_to_type(enrollment_row)).new(type: "AuthorizationRequest::#{from_target_api_to_type(enrollment_row)}")
  end

  def from_target_api_to_type(enrollment)
    {
      'hubee_portail' => 'hubee_cert_dc',
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
