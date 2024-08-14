Quand('le demandeur modifie le champ {string} avec la valeur {string}') do |field, value|
  Capybara.using_session(applicant_session(AuthorizationRequest.last)) do
    step "je me rends sur cette demande d'habilitation"
    step 'je clique sur "Modifier"'
    step "je remplis \"#{field}\" avec \"#{value}\""
    step 'je clique sur "Enregistrer"'
  end
end

Quand('le demandeur soumet la demande') do
  Capybara.using_session(applicant_session(AuthorizationRequest.last)) do
    step "je me rends sur cette demande d'habilitation"
    step 'je clique sur "Soumettre"'
  end
end
