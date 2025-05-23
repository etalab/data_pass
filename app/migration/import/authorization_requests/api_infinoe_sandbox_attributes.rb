class Import::AuthorizationRequests::APIINFINOESandboxAttributes < Import::AuthorizationRequests::APIRialSandboxAttributes
  def affect_data
    affect_form_uid
    super
  end

  def demarche_to_form_uid
    case enrollment_row['demarche']
    when 'envoi_ecritures'
      'api-infinoe-envoi-automatise-ecritures-sandbox'
    else
      'api-infinoe-sandbox'
    end
  end
end
