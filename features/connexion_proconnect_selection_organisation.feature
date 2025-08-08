# language: fr

Fonctionnalité: Connexion ProConnect
  En tant qu'utilisateur qui se connecte avec ProConnect, en fonction de mon fournisseur d'identité,
  je peux être amené à choisir ou ajouter mon organisation de rattachement.

  Contexte:
    Sachant que je suis rattaché à l'organisation "Ville de Clamart"

  Scénario: Connexion avec MonComptePro (organisation vérifiée, sans choix de l'organisation sur DataPass)
    Sachant que je suis un demandeur
    Et que je me connecte via ProConnect avec l'identité "MonComptePro"
    Alors je suis sur la page "Demandes et habilitations"
    Et la page contient "DUPONT Jean"
    Et il y a un message de succès contenant "Vous êtes connecté"
    Et l'organisation associée est marquée comme "vérifiée"
    Et l'organisation associée est marquée comme "ajoutée automatiquement"

  Scénario: Connexion avec un FI où le choix de l'organisation est nécessaire, je vois mes organisations
    Sachant que je suis un demandeur
    Et que je me connecte via ProConnect avec l'identité "Renater" qui renvoi l'organisation "DINUM"
    Alors je suis sur la page "Votre organisation de rattachement"
    Et la page contient "CLAMART"
    Et la page contient "DIRECTION INTERMINISTERIELLE DU NUMERIQUE"
    Et la page ne contient pas "Rejoindre une autre organisation"

  Scénario: Connexion avec un FI où le choix de l'organisation est nécessaire et où je peux rejoindre une organisation, un bouton pour rejoindre une autre organisation est visible
    Sachant que je suis un demandeur
    Et que je me connecte via ProConnect avec l'identité "DGFIP" qui renvoi l'organisation "DINUM"
    Alors je suis sur la page "Votre organisation de rattachement"
    Et la page contient "Rejoindre une autre organisation"

  Scénario: Si je suis associée à un fournisseur d'identité qui ne me permet pas de choisir une organisation, je ne peux pas en ajouter
    Sachant que je suis un demandeur
    Et que je me connecte via ProConnect avec l'identité "MonComptePro"
    Et que je me rends sur le chemin "/organisations/nouveau"
    Alors je suis sur la page "Demandes et habilitations"
    Et il y a un message d'erreur contenant "pas le droit d'accéder"

