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
