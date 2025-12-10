# language: fr

Fonctionnalité: Développeurs: gestion des webhooks
  En tant que développeur
  Je veux gérer mes webhooks
  Afin de recevoir des notifications lors de changements d'état des demandes

  Contexte:
    Sachant que je suis un développeur "API Entreprise"
    Et que je me connecte

  Scénario: Je peux créer un nouveau webhook
    Quand je me rends sur le chemin "/developpeurs/webhooks"
    Et que je clique sur "Nouveau webhook"
    Et que je sélectionne "API Entreprise" pour "Service"
    Et que je remplis "URL de destination" avec "https://webhook.site/test"
    Et que je coche "Approbation"
    Et que je coche "Soumission"
    Et que je clique sur "Créer le webhook"
    Alors la page contient "Secret du webhook"
    Et la page contient "Attention - Sauvegardez ce secret maintenant"
    Et je vois un secret de 64 caractères

  Scénario: Le secret est affiché une seule fois après la création
    Quand je me rends sur le chemin "/developpeurs/webhooks"
    Et que je clique sur "Nouveau webhook"
    Et que je sélectionne "API Entreprise" pour "Service"
    Et que je remplis "URL de destination" avec "https://webhook.site/test"
    Et que je coche "Approbation"
    Et que je clique sur "Créer le webhook"
    Alors je vois un secret de 64 caractères
    Quand je clique sur "Retour aux webhooks"
    Alors la page contient "https://webhook.site/test"
    Et la page ne contient pas le secret affiché précédemment

  Scénario: Je peux voir la liste de mes webhooks
    Sachant qu’il existe un webhook pour "API Entreprise" avec l'URL "https://webhook.site/test1"
    Et qu’il existe un webhook pour "API Entreprise" avec l'URL "https://webhook.site/test2"
    Quand je me rends sur le chemin "/developpeurs/webhooks"
    Alors la page contient "https://webhook.site/test1"
    Et la page contient "https://webhook.site/test2"

  Scénario: Je peux éditer un webhook
    Sachant qu’il existe un webhook pour "API Entreprise" avec l'URL "https://webhook.site/old"
    Quand je me rends sur le chemin "/developpeurs/webhooks"
    Et que je clique sur "Modifier"
    Et que je remplis "URL de destination" avec "https://webhook.site/new"
    Et que je clique sur "Mettre à jour"
    Alors la page contient "Webhook mis à jour avec succès"
    Et la page contient "https://webhook.site/new"

  Scénario: Je peux supprimer un webhook
    Sachant qu’il existe un webhook pour "API Entreprise" avec l'URL "https://webhook.site/test"
    Quand je me rends sur le chemin "/developpeurs/webhooks"
    Et que je clique sur "Supprimer"
    Alors la page contient "Webhook supprimé avec succès"
    Et la page ne contient pas "https://webhook.site/test"

  Scénario: Je peux voir l’historique des appels d’un webhook
    Sachant qu’il existe un webhook pour "API Entreprise" avec l'URL "https://webhook.site/test"
    Et que ce webhook a reçu 3 appels
    Quand je me rends sur le chemin "/developpeurs/webhooks"
    Et que je clique sur "Voir les appels"
    Alors la page contient "Historique des appels"
    Et je vois 3 appels dans la liste

  Scénario: Je peux consulter les détails d’un appel webhook
    Sachant qu’il existe un webhook pour "API Entreprise" avec l'URL "https://webhook.site/test"
    Et que ce webhook a reçu un appel avec le statut "200"
    Quand je me rends sur le chemin des appels de ce webhook
    Et que je clique sur le premier appel
    Alors la page contient "Détails de l'appel"
    Et la page contient "Statut"
    Et la page contient "200"
    Et la page contient "Approbation"

  Scénario: Je peux activer un webhook
    Sachant qu’il existe un webhook pour "API Entreprise" avec l'URL "https://webhook.site/test"
    Quand je me rends sur le chemin "/developpeurs/webhooks"
    Et que je clique sur "Activer"
    Alors la page contient "Webhook activé avec succès"
    Et je vois le badge "Actif"

  Scénario: Je ne peux pas activer un webhook avec une URL invalide
    Sachant qu’il existe un webhook pour "API Entreprise" avec l'URL "https://webhook.site/invalid"
    Quand je me rends sur le chemin "/developpeurs/webhooks"
    Et que je clique sur "Activer"
    Alors la page contient "Impossible d'activer le webhook"
    Et la page contient "Code HTTP: 500"
    Et la page contient "Internal Server Error"
    Et je vois le badge "Inactif"

  Scénario: Je peux désactiver un webhook activé
    Sachant qu’il existe un webhook activé pour "API Entreprise" avec l'URL "https://webhook.site/test"
    Quand je me rends sur le chemin "/developpeurs/webhooks"
    Et que je clique sur "Désactiver"
    Alors la page contient "Webhook désactivé avec succès"
    Et je vois le badge "Inactif"

  Scénario: Je peux rejouer un appel webhook
    Sachant qu’il existe un webhook activé pour "API Entreprise" avec l'URL "https://webhook.site/test"
    Et que ce webhook a reçu un appel avec le statut "200"
    Quand je me rends sur le chemin des appels de ce webhook
    Et que je clique sur "Voir détails" pour le premier appel
    Et que je clique sur "Rejouer cet appel"
    Alors la page contient "Appel rejoué avec succès"

  Scénario: Je peux régénérer le secret d’un webhook
    Sachant qu’il existe un webhook pour "API Entreprise" avec l'URL "https://webhook.site/test"
    Quand je me rends sur le chemin "/developpeurs/webhooks"
    Et que je clique sur "Régénérer le secret"
    Alors la page contient "Secret du webhook"
    Et la page contient "Attention - Sauvegardez ce secret maintenant"
    Et je vois un secret de 64 caractères
