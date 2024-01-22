class Import::AuthorizationRequests::HubEECertDCAttributes < Import::AuthorizationRequests::Base
  def affect_data
    handle_missing_applicant
    handle_missing_organization
    handle_multiple_organizations
    handle_administrateur_metier
  end

  private

  def handle_missing_applicant
    raise SkipRow.new(:no_applicant) if authorization_request.applicant.blank?
  end

  def handle_missing_organization
    raise SkipRow.new(:no_organization) if authorization_request.organization.blank?
  end

  def handle_multiple_organizations
    other_authorization_request = AuthorizationRequest::HubEECertDC.find_by(organization_id: authorization_request.organization_id)

    return if other_authorization_request.blank?

    case other_authorization_request.state
    when 'validated'
      raise SkipRow.new(:validated_one_already_exists)
    else
      other_authorization_request.destroy!
    end
  end

  def handle_administrateur_metier
    responsable_metier_team_member = find_team_member_by_type('responsable_metier')

    if authorization_request.draft?
      affect_team_attributes(responsable_metier_team_member, 'administrateur_metier')
    elsif team_member_incomplete?(responsable_metier_team_member)
      if responsable_metier_team_member['email'] == authorization_request.applicant.email
        # FIXME harden this case
        virtual_user = responsable_metier_team_member.to_h.merge(
          authorization_request.applicant.attributes.slice(*AuthorizationRequest.contact_attributes)
        )

        affect_team_attributes(virtual_user, 'administrateur_metier')
      else
        raise SkipRow.new(:partial_administrateur_metier_mismatch_with_applicant)
      end
    else
      affect_team_attributes(responsable_metier_team_member, 'administrateur_metier')
    end

    return if authorization_request.valid?

    raise SkipRow.new(:not_enough_data_for_administrateur_metier)
  end
end
