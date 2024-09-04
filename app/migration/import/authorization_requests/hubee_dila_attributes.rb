class Import::AuthorizationRequests::HubEEDilaAttributes < Import::AuthorizationRequests::HubEECertDCAttributes
  def affect_data
    if already_imported_valid?
      already_imported = other_models.find { |another_authorization_request| another_authorization_request.state == 'validated' }

      affect_additional_scopes(already_imported)
    end

    affect_scopes

    skip_row!(:refused_without_scopes) if authorization_request.state == 'refused' && authorization_request.scopes.blank?

    common_affect_data
  end

  protected

  def authorization_request_type
    'AuthorizationRequest::HubEEDila'
  end

  private

  def affect_additional_scopes(already_imported)
    if enrollment_row['scopes'].blank? || enrollment_row['scopes'] == '{}'
      scopes = []
    elsif enrollment_row['scopes'].is_a?(Array)
      scopes = enrollment_row['scopes']
    else
      scopes = enrollment_row['scopes'][1..-2].split(',')
    end

    already_imported.scopes += scopes
    already_imported.scopes.uniq!
    already_imported.save!
  end
end
