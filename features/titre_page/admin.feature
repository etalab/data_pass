# language: fr

Fonctionnalité: Titres de page de l'espace admin
  En tant qu'administrateur
  Je veux voir des titres de page pertinents pour les pages d'administration
  Afin de pouvoir identifier facilement ces pages dans l’historique et les onglets

  Scénario: Le titre de la page d'accueil admin est Espace administrateur
    Sachant que je suis un administrateur
    Et que je me connecte
    Quand je me rends sur le chemin "/admin"
    Alors le titre de la page est "Espace administrateur - DataPass"

  Scénario: Le titre de la page des utilisateurs avec rôles est Utilisateurs avec rôles
    Sachant que je suis un administrateur
    Et que je me connecte
    Quand je me rends sur le chemin "/admin/utilisateurs-avec-roles"
    Alors le titre de la page est "Utilisateurs avec rôles - DataPass"

  Scénario: Le titre de la page des emails en liste blanche est Emails en liste blanche
    Sachant que je suis un administrateur
    Et que je me connecte
    Quand je me rends sur le chemin "/admin/emails-verifies"
    Alors le titre de la page est "Emails en liste blanche - DataPass"
