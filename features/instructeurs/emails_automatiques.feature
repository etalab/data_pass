# language: fr

Fonctionnalité: Emails automatiques d'un formulaire
  Un instructeur peut consulter la liste des emails automatiques
  envoyés par DataPass pour un formulaire donné.

  @CreateDataProviders
  Scénario: Je consulte les emails automatiques depuis la page formulaire
    Sachant que je suis un rapporteur "API Entreprise"
    Et que je me connecte
    Quand je me rends sur le chemin "/instruction/fournisseurs-donnees/dinum/formulaires/api_entreprise"
    Alors la page contient "Emails automatiques"
    Quand je clique sur "Emails automatiques"
    Alors le titre de la page contient "Emails automatiques"
    Et la page contient "Soumission d'une demande"
    Et la page contient "Demandeur"

  @CreateDataProviders
  Scénario: La page des emails automatiques liste les emails avec leur sujet
    Sachant que je suis un rapporteur "API Entreprise"
    Et que je me connecte
    Quand je me rends sur le chemin "/instruction/fournisseurs-donnees/dinum/formulaires/api_entreprise/emails-automatiques"
    Alors le titre de la page contient "Emails automatiques"
    Et la page contient "Nous accusons réception"
    Et la page contient "Instructeurs"
