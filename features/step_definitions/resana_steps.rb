Quand('je remplis le cadre juridique et les personnes impliquées de la demande Resana') do
  steps %(
    * je remplis le cadre juridique de la demande Resana
    * je remplis les personnes impliquées de la demande Resana
  )
end

Quand('je remplis le cadre juridique de la demande Resana') do
  steps %(
    * je sélectionne "Établissement public administratif" pour "Nature juridique de votre structure"
    * je coche "Je certifie être habilité par ma hiérarchie à exercer le rôle d’administrateur Resana pour cette organisation"
    * je clique sur "Suivant"
  )
end

Quand('je remplis les personnes impliquées de la demande Resana') do
  steps %(
    * je remplis les informations du contact "Délégué à la protection des données" avec :
      | Nom    | Prénom  | Email                  | Téléphone  |
      | Dupont | Jacques | dupont.jacques@gouv.fr | 0836656565 |
    * je remplis les informations du contact "Responsable métier" avec :
      | Nom    | Prénom | Email               | Téléphone  | Poste occupé                   |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0836656565 | Chef de projet                 |
    * je clique sur "Suivant"
  )
end

Alors('la carte de contact {string} contient {string}') do |contact_title, text|
  expect(find('.contact-form-card__title', text: contact_title).find(:xpath, '../../..')).to have_text(text)
end

Alors('la carte de contact {string} ne propose pas de bouton {string}') do |contact_title, button|
  expect(find('.contact-form-card__title', text: contact_title).find(:xpath, '../../..')).to have_no_button(button)
end

Alors('la carte de contact {string} propose un bouton {string}') do |contact_title, button|
  expect(find('.contact-form-card__title', text: contact_title).find(:xpath, '../../..')).to have_button(button)
end
