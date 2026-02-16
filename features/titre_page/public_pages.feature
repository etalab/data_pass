# language: fr

Fonctionnalité: Titres de page des pages publiques
  En tant qu'utilisateur
  Je veux voir des titres de page pertinents dans mon navigateur
  Afin de pouvoir identifier facilement les pages dans l'historique et les onglets

  Scénario: Le titre de la page d'accueil est Accueil - DataPass
    Quand je me rends sur le chemin "/"
    Alors le titre de la page est "Accueil - DataPass"

  Scénario: Le titre de la page de demande d'habilitation est Demander une habilitation - DataPass
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je me rends sur le chemin "/demandes"
    Alors le titre de la page est "Demander une habilitation - DataPass"

  Scénario: Le titre de la page des statistiques est statistiques
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je me rends sur le chemin "/stats"
    Alors le titre de la page est "Statistiques - DataPass"

  Scénario: Le titre de la page FAQ est Foire aux questions
    Quand je me rends sur le chemin "/faq"
    Alors le titre de la page est "Foire aux questions - DataPass"

  Scénario: Le titre de la page d'accessibilité est Déclaration d'accessibilité
    Quand je me rends sur le chemin "/accessibilite"
    Alors le titre de la page est "Déclaration d’accessibilité - DataPass"

  Scénario: Le titre de la page des mentions légales est Mentions légales
    Quand je me rends sur le chemin "/mentions-legales"
    Alors le titre de la page est "Mentions légales - DataPass"

  Scénario: Le titre de la page de politique de confidentialité est Politique de confidentialité
    Quand je me rends sur le chemin "/politique-confidentialite"
    Alors le titre de la page est "Politique de confidentialité - DataPass"

  Scénario: Le titre de la page CGU API Impôt Particulier (bac à sable) est CGU API Impôt Particulier - Bac à sable - DataPass
    Quand je me rends sur le chemin "/cgu_api_impot_particulier_bas"
    Alors le titre de la page est "CGU API Impôt Particulier - Bac à sable - DataPass"

  Scénario: Le titre de la page CGU API Impôt Particulier (production) est CGU API Impôt Particulier - Production - DataPass
    Quand je me rends sur le chemin "/cgu_api_impot_particulier_prod"
    Alors le titre de la page est "CGU API Impôt Particulier - Production - DataPass"
