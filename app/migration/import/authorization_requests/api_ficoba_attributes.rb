class Import::AuthorizationRequests::APIFicobaAttributes < Import::AuthorizationRequests::APIRialAttributes
  def affect_data
    affect_form_uid

    super
  end

  def demarche_to_form_uid
    form_uid = 'api-ficoba-production'
    form_uid += '-editeur' if enrollment_row['target_api'] =~ /_unique$/
    form_uid
  end
end
