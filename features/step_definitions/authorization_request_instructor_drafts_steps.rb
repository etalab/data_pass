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
