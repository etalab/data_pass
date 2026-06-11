# language: fr

Fonctionnalité: Développeurs: gestion des clefs API
  En tant que développeur
  Je veux créer et supprimer mes clefs API
  Afin de gérer mon accès à l'API DataPass

  Contexte:
    Sachant que je suis un développeur "API Entreprise"
    Et que je me connecte

  Scénario: Je peux créer une clef API
    Quand je me rends sur le chemin "/developpeurs/applications"
    Et que je clique sur "Nouvelle clef API"
    Et que je remplis "Nom de l'application" avec "Mon application"
    Et que je clique sur "Créer la clef API"
    Alors la page contient "Mes clefs d'accès API"
    Et il y a un message de succès contenant "Clef API créée avec succès"
    Et la page contient "Mon application"

  Scénario: Je ne peux pas créer une clef API sans nom
    Quand je me rends sur le chemin "/developpeurs/applications"
    Et que je clique sur "Nouvelle clef API"
    Et que je clique sur "Créer la clef API"
    Alors la page contient "erreur"

  Scénario: Je peux supprimer une de mes clefs API
    Sachant qu'il existe une application OAuth "App à supprimer" appartenant au développeur courant
    Quand je me rends sur le chemin "/developpeurs/applications"
    Et que je clique sur "Supprimer" dans la rangée "App à supprimer"
    Alors il y a un message de succès contenant "Clef API supprimée avec succès"
    Et la page ne contient pas "App à supprimer"

  Scénario: Je ne peux pas supprimer une clef API qui ne m'appartient pas
    Sachant qu'il existe une application OAuth appartenant à un autre développeur
    Quand j'essaie de supprimer cette application directement
    Alors l'application n'a pas été supprimée
