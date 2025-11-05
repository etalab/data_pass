# language: fr

Fonctionnalité: Titres de page des pages de sélection de formulaire
  En tant qu'utilisateur
  Je veux voir des titres de page pertinents pour les pages de sélection de formulaire
  Afin de pouvoir identifier facilement ces pages dans l'historique et les onglets

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Le titre de la page de sélection API Entreprise est correct
    Quand je me rends sur le chemin "/demandes/api-entreprise/nouveau"
    Alors le titre de la page contient "Choix du cas d&#39;usage - API Entreprise - DataPass"

  Scénario: Le titre de la page de sélection API Particulier est correct
    Quand je me rends sur le chemin "/demandes/api-particulier/nouveau"
    Alors le titre de la page contient "Choix du cas d&#39;usage - API Particulier - DataPass"

  Scénario: Le titre de la page de sélection API Impôt Particulier est correct
    Quand je me rends sur le chemin "/demandes/api-impot-particulier/nouveau"
    Alors le titre de la page contient "Choix de la modalité d&#39;accès - API Impôt Particulier - DataPass"

  Scénario: Le titre de la page de sélection API SFiP est correct
    Quand je me rends sur le chemin "/demandes/api-sfip/nouveau"
    Alors le titre de la page contient "Choix du type de données - API SFiP - DataPass"

  Scénario: Le titre de la page de sélection API Ficoba est correct
    Quand je me rends sur le chemin "/demandes/api-ficoba/nouveau"
    Alors le titre de la page contient "Choix du cas d&#39;usage - API Ficoba - DataPass"

  Scénario: Le titre de la page de sélection API Infinoe est correct
    Quand je me rends sur le chemin "/demandes/api-infinoe/nouveau"
    Alors le titre de la page contient "Choix du cas d&#39;usage - API Infinoe - DataPass"

  Scénario: Le titre de la page de sélection API Droits CNAM est correct
    Quand je me rends sur le chemin "/demandes/api-droits-cnam/nouveau"
    Alors le titre de la page contient "Choix du cas d&#39;usage - API Droits CNAM - DataPass"

  Scénario: Le titre de la page de sélection API R2P est correct
    Quand je me rends sur le chemin "/demandes/api-r2p/nouveau"
    Alors le titre de la page contient "Information - API R2P - DataPass"