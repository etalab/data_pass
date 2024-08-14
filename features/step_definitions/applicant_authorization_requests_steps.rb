Quand('le demandeur modifie le champ {string} avec la valeur {string}') do |field, value|
  using_last_applicant_session do
    step "je me rends sur cette demande d'habilitation"
    step 'je clique sur "Modifier"'
    step "je remplis \"#{field}\" avec \"#{value}\""
    step 'je clique sur "Enregistrer"'
  end
end

Quand('le demandeur soumet la demande') do
  using_last_applicant_session do
    step "je me rends sur cette demande d'habilitation"
    step 'je clique sur "Soumettre"'
  end
end
