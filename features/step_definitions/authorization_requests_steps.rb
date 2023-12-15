Quand("je démarre une nouvelle demande d'habilitation {string}") do |string|
  form_uid = AuthorizationRequestForm.where(name: string).first.uid

  visit new_authorization_request_path(form_uid:)
end
