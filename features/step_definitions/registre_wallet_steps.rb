Quand('je me rends sur la page de démarrage du registre wallet') do
  visit authorization_request_form_introduction_path(form_uid: 'registre-wallet')
end

Sachantque('le répertoire Sirene n’a pas encore renseigné mon organisation') do
  current_user!.current_organization.update!(insee_payload: nil)
end
