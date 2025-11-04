# language: fr

Fonctionnalité: Titres de page des pages publiques
  En tant qu'utilisateur
  Je veux voir des titres de page pertinents dans mon navigateur
  Afin de pouvoir identifier facilement les pages dans l'historique et les onglets

  Scénario: Le titre de la page d'accueil est correct
    Quand je me rends sur le chemin "/"
    Alors le titre de la page contient "Accueil - DataPass"

  Scénario: Le titre de la page de demande d'habilitation est correct
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je me rends sur le chemin "/demandes"
    Alors le titre de la page contient "Demander une habilitation - DataPass"

  Scénario: Le titre de la page des statistiques est correct
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je me rends sur le chemin "/stats"
    Alors le titre de la page contient "Statistiques - DataPass"

  Scénario: Le titre de la page FAQ est correct
    Quand je me rends sur le chemin "/faq"
    Alors le titre de la page contient "Foire aux questions - DataPass"

  Scénario: Le titre de la page d'accessibilité est correct
    Quand je me rends sur le chemin "/accessibilite"
    Alors le titre de la page contient "Déclaration d’accessibilité - DataPass"

  Scénario: Le titre de la page CGU API Impôt Particulier (bac à sable) est correct
    Quand je me rends sur le chemin "/cgu_api_impot_particulier_bas"
    Alors le titre de la page contient "CGU API Impôt Particulier - Bac à sable - DataPass"

  Scénario: Le titre de la page CGU API Impôt Particulier (production) est correct
    Quand je me rends sur le chemin "/cgu_api_impot_particulier_prod"
    Alors le titre de la page contient "CGU API Impôt Particulier - Production - DataPass"