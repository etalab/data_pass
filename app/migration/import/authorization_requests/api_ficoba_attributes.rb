class Import::AuthorizationRequests::APIFicobaAttributes < Import::AuthorizationRequests::APIRialAttributes
  def extra_affect_data
    affect_form_uid
  end

  def demarche_to_form_uid
    form_uid = 'api-ficoba-production'
    form_uid += '-editeur' if enrollment_row['target_api'] =~ /_unique$/
    form_uid
  end
end
