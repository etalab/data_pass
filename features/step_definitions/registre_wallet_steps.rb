Quand('je me rends sur la page de démarrage du registre wallet') do
  visit new_authorization_request_form_path(form_uid: 'registre-wallet')
end

Sachantque('le répertoire Sirene n’a pas encore renseigné mon organisation') do
  current_user!.current_organization.update!(insee_payload: nil)
end

Quand('je me rends sur la page de démarrage du registre wallet en répondant {string}') do |answer|
  profil = { 'le dirigeant d’une entreprise' => 'dirigeant', 'un agent public' => 'agent' }.fetch(answer)

  visit new_authorization_request_path(definition_id: 'registre-wallet', eligibility_confirmed: true, profil:)
end

Quand('je me rends sur l’arbre d’éligibilité du registre wallet') do
  visit new_authorization_request_path(definition_id: 'registre-wallet')
end
