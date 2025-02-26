class Import::AuthorizationRequests::APIDeclarationCESUAttributes < Import::AuthorizationRequests::APIDeclarationAutoEntrepreneurAttributes
  def affect_form_uid
    authorization_request.form_uid = 'api-declaration-cesu'
  end
end
