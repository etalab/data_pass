Sachantque("j'ai une demande API Particulier certifiée FranceConnect avec modalité FranceConnect en cours de remplissage") do
  @authorization_request = FactoryBot.create(
    :authorization_request,
    :api_particulier_entrouvert_publik,
    :with_france_connect_embedded_fields,
    :draft_and_filled,
    applicant: current_user,
    organization: current_user.current_organization
  )
end

Sachantque("j'ai une demande API Particulier certifiée FranceConnect sans modalité FranceConnect en cours de remplissage") do
  @authorization_request = FactoryBot.create(
    :authorization_request,
    :api_particulier_entrouvert_publik,
    :draft_and_filled,
    applicant: current_user,
    organization: current_user.current_organization
  )
end

Quand('je me rends sur le résumé de cette demande') do
  visit summary_authorization_request_form_path(
    form_uid: @authorization_request.form.uid,
    id: @authorization_request.id
  )
end
