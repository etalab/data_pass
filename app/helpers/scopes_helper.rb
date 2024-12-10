module ScopesHelper
  def error_messages_for_scope_group(authorization_request, group_name)
    messages = []

    case group_name
    when 'Années sur lesquelles porte votre demande'
      messages << authorization_request.errors[:revenue_years] if authorization_request.errors[:revenue_years].any?
      messages << authorization_request.errors[:revenue_years_compatibility] if authorization_request.errors[:revenue_years_compatibility].any?
    end

    messages.flatten
  end
end
