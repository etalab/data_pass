Quand('je remplis le cadre juridique et les personnes impliquées de la demande Resana') do
  steps %(
    * je remplis "Précisez la nature et les références du texte vous autorisant à traiter les données" avec "Établissement public administratif"
    * je remplis "URL du texte relatif au traitement" avec "https://exemple.gouv.fr/cadre-juridique"
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
