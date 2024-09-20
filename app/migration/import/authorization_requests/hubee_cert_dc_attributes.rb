class Import::AuthorizationRequests::HubEECertDCAttributes < Import::AuthorizationRequests::Base
  def affect_data
    skip_row!(:already_imported_valid) if already_imported_valid?

    common_affect_data
  end

  def common_affect_data
    case authorization_request.state
    when 'archived'
      skip_row!(:archived)
    when 'draft', 'changes_requested'
      if other_models.any? { |another_authorization_request| %[draft changes_requested].include?(another_authorization_request.state) }
        skip_row!(:"more_recent_#{authorization_request.state}_exists")
      end

      other_models.select { |another_authorization_request| another_authorization_request.state == 'refused' }.map(&:delete)
    when 'refused'
      if other_models.any?
        skip_row!(:more_recent_for_current_refused)
      end
    when 'revoked'
      skip_row!(:revoked)
    end

    fetch_missing_applicant if authorization_request.applicant.blank?
    fetch_missing_organization if authorization_request.organization.blank?

    if responsable_metier_email.blank?
      warn_row!(:affect_applicant_to_administrateur_metier)

      team_members.map! do |team_member|
        if team_member['type'] == 'responsable_metier'
          team_member['email'] = authorization_request.applicant.email
        end

        team_member
      end
    end

    affect_contact('responsable_metier', 'administrateur_metier')

    if authorization_request.state == 'validated'
      authorization_request.organization.authorization_requests.where(type: authorization_request_type).delete_all
    end
  end

  protected

  def authorization_request_type
    'AuthorizationRequest::HubEECertDC'
  end

  private

  def already_imported_valid?
    other_models.any? do |another_authorization_request|
      another_authorization_request.state == 'validated'
    end
  end

  def other_models
    @other_models ||= [@all_models.find do |another_authorization_request|
      another_authorization_request.organization_id == authorization_request.organization_id &&
        another_authorization_request.type == authorization_request_type
    end].compact
  end

  def fetch_missing_applicant
    authorization_request.applicant ||= (User.find_by(email: responsable_metier_email) || User.find_by(email: subscription_email))

    return if authorization_request.applicant.present?

    create_applicant!
  end

  def fetch_missing_organization
    organization = authorization_request.organization = authorization_request.applicant.organizations.find do |organization|
      organization.siret == enrollment_row['siret']
    end

    return organization if organization.present?

    warn_row!(:create_organization)
    new_organization = (Organization.find_by(siret: enrollment_row['siret']) || create_organization!)

    authorization_request.applicant.organizations << new_organization
    authorization_request.organization_id = new_organization.id
  end

  def create_applicant!
    warn_row!(:missing_applicant)

    applicant_email = responsable_metier_email || subscription_email

    organization = Organization.find_by(siret: enrollment_row['siret'])

    if organization.blank?
      warn_row!(:missing_organization)

      organization = create_organization!
    end

    new_applicant = User.create(email: applicant_email, current_organization: organization)
    skip_row!(:no_valid_email_for_user) unless new_applicant.valid?

    new_applicant.organizations << organization

    authorization_request.applicant = new_applicant
  end

  def responsable_metier_email
    @responsable_metier_email ||= find_team_member_by_type('responsable_metier')['email'].try(:downcase).try(:strip)
  end

  def subscription_email
    @subscription_email ||= begin
      rows = database.execute("select * from hubee_subscriptions where siret = ?", enrollment_row['siret']).map { |r| JSON.parse(r[-1])}

      skip_row!(:no_hubee_subscriptions) unless rows.any?

      hubee_cert_dc_subscription = rows.find { |row| row['kind'] == 'hubee_cert_dc' }

      if valid_subscription_email?(hubee_cert_dc_subscription)
        possible_email = hubee_cert_dc_subscription['email']
      else
        valid_row = rows.find do |row|
          if valid_subscription_email?(row)
            row['email']
          else
            nil
          end
        end

        possible_email = valid_row['email'] if valid_row
      end

      if possible_email.present? && possible_email.include?(';')
        possible_email.split(';').find { |email| valid_subscription_email?({'email' => email}) }.try(:downcase).try(:strip)
      else
        possible_email.try(:downcase).try(:strip)
      end
    end
  end

  def valid_subscription_email?(data)
    data.present? &&
      %w[migration@hubee.com].exclude?(data['email'])
  end

  def create_organization!
    Organization.create!(siret: enrollment_row['siret'], mon_compte_pro_payload: { siret: enrollment_row['siret'] }, last_mon_compte_pro_updated_at: DateTime.now)
  end
end
