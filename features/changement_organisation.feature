# language: fr

Fonctionnalité: Changement d'organisation
  En tant qu'utilisateur connecté je peux changer à tout moment d'organisation.

  Contexte:
    Sachant que je suis un demandeur
    Et que je suis rattaché à l'organisation "Ville de Clamart"

  Scénario: Avec MonComptePro, je peux changer d'organisation
    Quand je me connecte via ProConnect avec l'identité "MonComptePro" qui renvoi l'organisation "DINUM"
    Et que je me rends sur le chemin "/tableau-de-bord"
    Et que je clique sur "Changer d'organisation"
    Et que je clique sur "CLAMART"
    Alors je suis sur la page "Demandes et habilitations"
    Et la page contient "CLAMART"

  Scénario: Avec MonComptePro, je dois me déconnecter pour ajouter une nouvelle organisation
    Quand je me connecte via ProConnect avec l'identité "MonComptePro" qui renvoi l'organisation "DINUM"
    Et que je me rends sur le chemin "/tableau-de-bord"
    Et que je clique sur "Changer d'organisation"
    Alors je suis sur la page "Votre organisation de rattachement"
    Et la page contient "CLAMART"
    Et la page contient "DIRECTION INTERMINISTERIELLE DU NUMERIQUE"
    Et la page contient "Se déconnecter pour rejoindre une autre organisation"
    Et la page ne contient pas "Rejoindre une autre organisation"

  Scénario: Avec un fournisseur d'identité où le choix de l'organisation est nécessaire, je peux changer d'organisation
    Quand je me connecte via ProConnect avec l'identité "Renater" qui renvoi l'organisation "DINUM"
    Et que je me rends sur le chemin "/tableau-de-bord"
    Et que je clique sur "Changer d'organisation"
    Et que je clique sur "CLAMART"
    Alors je suis sur la page "Demandes et habilitations"
    Et la page contient "CLAMART"
