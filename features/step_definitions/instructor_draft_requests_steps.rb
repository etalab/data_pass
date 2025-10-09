Quand("j'ai une demande d'habilitation à partager pour {string} intitulée {string}") do |authorization_request_name, intitule|
  create(
    :instructor_draft_request,
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
    :instructor_draft_request,
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
    :instructor_draft_request,
    applicant: user,
    organization: user.current_organization,
    data: {
      intitule: 'Projet de test',
    }
  )
end

Quand("je me rends sur cette invitation à remplir une demande d'habilitation") do
  instructor_draft_request = InstructorDraftRequest.last

  visit claim_instructor_draft_request_path(instructor_draft_request.public_id)
end

Quand("ce brouillon de demande d'habilitation a déjà été finalisée") do
  instructor_draft_request = InstructorDraftRequest.last
  instructor_draft_request.update!(claimed: true)
end

Quand("je me rends sur la page de gestion des demandes d'habilitation d'instructeur") do
  visit instruction_instructor_draft_requests_path
end
