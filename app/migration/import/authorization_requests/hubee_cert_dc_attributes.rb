class Import::AuthorizationRequests::HubEECertDCAttributes < Import::AuthorizationRequests::Base
  def affect_attributes
    handle_multiple_organizations
    handle_administrateur_metier
  end

  private

  def handle_multiple_organizations
    other_authorization_request = AuthorizationRequest::HubEECertDC.find_by(organization_id: authorization_request.organization_id)

    return if other_authorization_request.blank?

    case other_authorization_request.state
    when 'validated'
      raise SkipRow
    else
      other_authorization_request.destroy!
    end
  end

  def handle_administrateur_metier
    responsable_metier_team_member = find_team_member_by_type('responsable_metier')

    if authorization_request.draft?
      affect_team_attributes(responsable_metier_team_member, 'administrateur_metier')
    elsif team_member_incomplete?(responsable_metier_team_member)
      virtual_user = responsable_metier_team_member.merge(
        authorization_request.applicant.attributes.slice(**AuthorizationRequest.contact_attributes)
      )

      affect_team_attributes(virtual_user, 'administrateur_metier')
    else
      affect_team_attributes(responsable_metier_team_member, 'administrateur_metier')
    end
  end
end
