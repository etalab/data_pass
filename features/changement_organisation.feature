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

  Scénario: Avec MonComptePro, j'ai un bouton pour changer d'organisation
    Quand je me connecte via ProConnect avec l'identité "MonComptePro" qui renvoi l'organisation "DINUM"
    Et que je me rends sur le chemin "/tableau-de-bord"
    Et que je clique sur "Changer d'organisation"
    Alors je suis sur la page "Votre organisation de rattachement"
    Et la page contient "CLAMART"
    Et la page contient "DIRECTION INTERMINISTERIELLE DU NUMERIQUE"
    Et la page contient "Rejoindre une autre organisation"

  Scénario: Avec MonComptePro, je rejoins une autre organisation via ProConnect Identité
    Quand je me connecte via ProConnect avec l'identité "MonComptePro" qui renvoi l'organisation "DINUM"
    Et que ProConnect Identité renvoie l'organisation "Ville de Lyon"
    Et que je me rends sur le chemin "/tableau-de-bord"
    Et que je clique sur "Changer d'organisation"
    Et que je clique sur "Rejoindre une autre organisation"
    Alors je suis sur la page "Votre organisation de rattachement"
    Et la page contient "21690123100011"

  Scénario: Sans être connecté, je ne peux pas me connecter directement via ProConnect Identité
    Quand ProConnect Identité renvoie l'organisation "Ville de Lyon"
    Et que je me rends sur le chemin "/auth/mon_compte_pro/callback"
    Alors il y a un message d'erreur contenant "connectez-vous d’abord via ProConnect"
    Et la page contient "S’identifier avec ProConnect"

  Scénario: Avec un fournisseur d'identité où le choix de l'organisation est nécessaire, je peux changer d'organisation
    Quand je me connecte via ProConnect avec l'identité "Renater" qui renvoi l'organisation "DINUM"
    Et que je me rends sur le chemin "/tableau-de-bord"
    Et que je clique sur "Changer d'organisation"
    Et que je clique sur "CLAMART"
    Alors je suis sur la page "Demandes et habilitations"
    Et la page contient "CLAMART"
