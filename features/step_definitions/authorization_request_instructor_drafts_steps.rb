Quand("j'ai une demande d'habilitation à partager pour {string} intitulée {string}") do |authorization_request_name, intitule|
  create(
    :authorization_request_instructor_draft,
    authorization_request_class: find_authorization_request_class_from_name(authorization_request_name),
    instructor: @current_user,
    data: {
      intitule:,
    }
  )
end

Quand("on m'a invité à remplir une demande d'habilitation intitulée {string}") do |intitule|
  user = User.find_by(email: @current_user_email)

  create(
    :authorization_request_instructor_draft,
    applicant: user,
    organization: create(:organization),
    data: {
      intitule:,
    }
  )
end

Quand("il y a un brouillon de demande d'habilitation initiée pour l'usager {string}") do |email|
  user = User.find_by(email:) || create(:user, email:)

  create(
    :authorization_request_instructor_draft,
    applicant: user,
    organization: user.current_organization,
    data: {
      intitule: 'Projet de test',
    }
  )
end

Quand("je me rends sur cette invitation à remplir une demande d'habilitation") do
  authorization_request_draft = AuthorizationRequestInstructorDraft.last

  visit claim_authorization_request_instructor_draft_path(authorization_request_draft.public_id)
end

Quand("ce brouillon de demande d'habilitation a déjà été revendiquée") do
  authorization_request_draft = AuthorizationRequestInstructorDraft.last
  authorization_request_draft.update!(claimed: true)
end

Quand("je me rends sur la page de gestion des demandes d'habilitation d'instructeur") do
  visit instruction_authorization_request_instructor_drafts_path
end

Quand("je renseigne l'email {string}") do |email|
  fill_in 'applicant_email', with: email
end

Quand('je renseigne le siret {string}') do |siret|
  if siret == '13002526500013'
    extend INSEESireneAPIMocks
    mock_insee_sirene_api_etablissement_valid(siret: siret)
  end
  fill_in 'organization_siret', with: siret
end

Quand('je clique sur le bouton {string}') do |button_text|
  if button_text == 'Envoyer l\'invitation'
    click_button button_text
  else
    click_link button_text
  end
end

Alors('je vois le message {string}') do |message|
  expect(page).to have_content(message)
end

Alors("un email d'invitation est envoyé à {string}") do |email|
  expect(ActionMailer::Base.deliveries.last.to).to include(email)
end

Alors("je vois le message d'erreur") do
  expect(page).to have_content('Erreur lors de l\'envoi de l\'invitation')
end

Étantdonnéque('je suis un instructeur') do
  user = create_instructor('API Entreprise')

  @current_user_email = user.email
  @current_user = user
  mock_identity_federators(user)
  
  using_user_session(user) do
  end
end

