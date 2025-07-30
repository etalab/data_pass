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

  Scénario: Connexion avec un FI où le choix de l'organisation est nécessaire, je vois mes organisations
    Sachant que je suis un demandeur
    Et que je me connecte via ProConnect avec l'identité "Renater" qui renvoi l'organisation "DINUM"
    Alors je suis sur la page "Votre organisation de rattachement"
    Et la page contient "CLAMART"
    Et la page contient "DIRECTION INTERMINISTERIELLE DU NUMERIQUE"
    Et la page contient "Rejoindre une autre organisation"
