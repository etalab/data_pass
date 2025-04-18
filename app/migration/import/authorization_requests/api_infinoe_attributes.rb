class Import::AuthorizationRequests::APIINFINOEAttributes < Import::AuthorizationRequests::APIRialAttributes
  def affect_data
    super
    affect_form_uid
  end

  def demarche_to_form_uid
    form_uid = case enrollment_row['demarche']
      when 'envoi_ecritures'
        'api-infinoe-envoi-automatise-ecritures-production'
      else
        'api-infinoe-production'
      end

    form_uid += '-editeur' if enrollment_row['target_api'] =~ /_unique$/

    form_uid
  end
end
