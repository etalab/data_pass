# language: fr

Fonctionnalité: Espace admin: emails en liste blanche
  En tant qu'administrateur, je peux voir les emails en liste blanche et en ajouter des supplémentaires,
  dans le cas où on nous contacte au support et qu'on nous certifie que l'email est bien valide

  Contexte:
    Sachant que je suis un administrateur
    Et que je me connecte

  Scénario: Je peux consulter les emails en liste blanche
    Quand il y a l'email "liste-blanche@gouv.fr" marqué en tant que "liste blanche"
    Et qu'il y a l'email "delivrable@gouv.fr" marqué en tant que "délivrable"
    Et que je me rends sur le module "Emails vérifiés" de l'espace administrateur
    Alors la page contient "liste-blanche@gouv.fr"
    Et la page ne contient pas "delivrable@gouv.fr"

  Scénario: Je peux ajouter un email en liste blanche
    Quand je me rends sur le module "Emails vérifiés" de l'espace administrateur
    Et que je clique sur "Ajouter un email"
    Et que je remplis "Email" avec "nouveau@gouv.fr"
    Et que je clique sur "Valider"
    Alors la page contient "nouveau@gouv.fr"
    Et il y a un message de succès contenant "a été ajouté"

