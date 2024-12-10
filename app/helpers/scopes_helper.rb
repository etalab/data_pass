module ScopesHelper
  def error_messages_for_scope_group(authorization_request, group_name)
    messages = []

    case group_name
      when 'Années sur lesquelles porte votre demande'
        messages << authorization_request.errors[:revenue_years] if authorization_request.errors[:revenue_years].any?
        messages << authorization_request.errors[:revenue_years_compatibility] if authorization_request.errors[:revenue_years_compatibility].any?
      when *DGFIPExtensions::APIImpotParticulierScopes::SCOPE_ERROR_MESSAGES[:income_data_incompatibility][:groups]
        messages << authorization_request.errors[:income_data_incompatibility] if authorization_request.errors[:income_data_incompatibility].any?
    end

    messages.flatten
  end

  def specific_requirements_error(authorization_request)
    authorization_request.errors[:specific_requirements] if authorization_request.errors[:specific_requirements].any?
  end

end
