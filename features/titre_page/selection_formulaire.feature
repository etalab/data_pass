# language: fr

Fonctionnalité: Titres de page des pages de sélection de formulaire
  En tant qu'utilisateur
  Je veux voir des titres de page pertinents pour les pages de sélection de formulaire
  Afin de pouvoir identifier facilement ces pages dans l’historique et les onglets

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Le titre de la page de sélection API Entreprise est Choix du cas d'usage - nom de l’API - DataPass
    Quand je me rends sur le chemin "/demandes/api-entreprise/nouveau"
    Alors le titre de la page est "Choix du cas d’usage - API Entreprise - DataPass"

  Scénario: Le titre de la page de sélection API Particulier est Choix du cas d'usage - nom de l’API - DataPass
    Quand je me rends sur le chemin "/demandes/api-particulier/nouveau"
    Alors le titre de la page est "Choix du cas d’usage - API Particulier - DataPass"

  Scénario: Le titre de la page de sélection API Impôt Particulier est Choix de la modalité d’accès - nom de l’API - DataPass
    Quand je me rends sur le chemin "/demandes/api-impot-particulier/nouveau"
    Alors le titre de la page est "Choix de la modalité d’accès - API Impôt Particulier - DataPass"

  Scénario: Le titre de la page de sélection API SFiP est Choix du type de données - API - DataPass
    Quand je me rends sur le chemin "/demandes/api-sfip/nouveau"
    Alors le titre de la page est "Choix du type de données - API Courtier fonctionnel SFiP - DataPass"

  Scénario: Le titre de la page de sélection API Ficoba est Choix du cas d'usage - nom de l’API - DataPass
    Quand je me rends sur le chemin "/demandes/api-ficoba/nouveau"
    Alors le titre de la page est "Choix du cas d’usage - API Fichier des Comptes Bancaires et Assimilés (FICOBA) - DataPass"

  Scénario: Le titre de la page de sélection API Infinoe est Choix du cas d'usage - nom de l’API - DataPass
    Quand je me rends sur le chemin "/demandes/api-infinoe/nouveau"
    Alors le titre de la page est "Choix du cas d’usage - API INFINOE - DataPass"

  Scénario: Le titre de la page de sélection API Droits CNAM est correct
    Quand je me rends sur le chemin "/demandes/api-droits-cnam/nouveau"
    Alors le titre de la page est "Habilitation France Connect manquante - API de droits à l'Assurance Maladie - DataPass"

  Scénario: Le titre de la page de sélection API R2P est Information - nom de l’API - DataPass
    Quand je me rends sur le chemin "/demandes/api-r2p/nouveau"
    Alors le titre de la page est "Information - API R2P - DataPass"
