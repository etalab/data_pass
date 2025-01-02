Quand('je veux remplir une demande pour API Impot Particulier via le formulaire {string} en bac à sable') do |authorization_request_form_name|
  authorization_request_forms = AuthorizationRequestForm.where(
    name: authorization_request_form_name,
    authorization_request_class: AuthorizationRequest::APIImpotParticulierSandbox
  )

  raise "More than one form found for #{authorization_request_form_name} for API Impot Particulier" if authorization_request_forms.count > 1

  visit new_authorization_request_form_path(form_uid: authorization_request_forms.first.uid)
end
