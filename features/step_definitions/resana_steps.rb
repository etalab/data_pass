Quand('je remplis le cadre juridique et les personnes impliquées de la demande Resana') do
  steps %(
    * je sélectionne "Établissement public administratif" pour "Nature juridique de votre structure"
    * je coche "Je certifie être habilité par ma hiérarchie à exercer le rôle d’administrateur Resana pour cette organisation"
    * je clique sur "Suivant"

    * je remplis les informations du contact "Délégué à la protection des données" avec :
      | Nom    | Prénom  | Email                  | Téléphone  | Fonction du délégué à la protection des données |
      | Dupont | Jacques | dupont.jacques@gouv.fr | 0836656565 | DPO                                             |
    * je remplis les informations du contact "Contact métier" avec :
      | Nom    | Prénom | Email               | Téléphone  | Fonction du contact métier |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0836656565 | Chef de projet             |
    * je clique sur "Suivant"
  )
end
