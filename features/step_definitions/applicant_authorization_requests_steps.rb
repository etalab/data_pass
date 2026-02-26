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

Quand("le demandeur réouvre l'habilitation") do
  using_last_applicant_session do
    step 'je me rends sur mon tableau de bord demandeur habilitations'
    step 'je clique sur "Mettre à jour"'
    step 'je clique sur "Mettre à jour l\'habilitation"'
  end
end

Quand('le demandeur coche {string} dans la section {string}') do |checkbox_label, section_title|
  using_last_applicant_session do
    step "je clique sur \"Modifier\" dans le bloc de résumé \"#{section_title}\""
    step "je coche \"#{checkbox_label}\""
    step 'je clique sur "Enregistrer les modifications"'
  end
end

Quand('le demandeur soumet la demande de mise à jour') do
  using_last_applicant_session do
    step 'je clique sur "Envoyer ma demande de modification"'
  end
end
