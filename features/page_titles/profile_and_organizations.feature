# language: fr

Fonctionnalité: Titres de page du profil et des organisations
  En tant qu'utilisateur connecté
  Je veux voir des titres de page pertinents pour mon profil et mes organisations
  Afin de pouvoir identifier facilement ces pages dans l'historique et les onglets

  Scénario: Le titre de la page de profil est correct
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je me rends sur le chemin "/compte"
    Alors le titre de la page contient "Votre compte utilisateur - DataPass"

  Scénario: Le titre de la page des organisations est correct
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je me rends sur le chemin "/usager/organisations"
    Alors le titre de la page contient "Choix de votre organisation - DataPass"
