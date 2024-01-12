class Import::AuthorizationRequests::HubEECertDCAttributes < Import::AuthorizationRequests::Base
  def affect_attributes
    responsable_metier_team_member = find_team_member_by_type('responsable_metier')

    AuthorizationRequest.contact_attributes.each do |contact_attribute|
      from_contact_attribute = contact_attribute == 'job_title' ? 'job' : contact_attribute

      authorization_request.send(
        "administrateur_metier_#{contact_attribute}=",
        responsable_metier_team_member[from_contact_attribute] ||
          authorization_request.applicant.send(contact_attribute)
      )
    end
  end
end
