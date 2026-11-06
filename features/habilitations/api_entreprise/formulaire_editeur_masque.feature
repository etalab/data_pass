# language: fr

Fonctionnalité: Formulaire éditeur d’API Entreprise masqué
  Les éditeurs sont orientés vers le questionnaire de qualification, le formulaire
  éditeur n’est plus proposé mais les demandes existantes restent accessibles.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Le formulaire éditeur n’est plus démarrable par lien direct
    Quand je vais sur la page formulaires/api-entreprise-editeur/demande/nouveau
    Alors la page ne contient pas "Formulaire spécifique aux éditeurs de logiciels"
    Et il y a un message d'erreur contenant "Ce formulaire n’est plus disponible pour déposer une nouvelle demande"

  Scénario: La première page du formulaire éditeur n’est pas affichée par lien direct
    Quand je vais sur la page formulaires/api-entreprise-editeur/demande/commencer
    Alors la page ne contient pas "Formulaire spécifique aux éditeurs de logiciels"
    Et il y a un message d'erreur contenant "Vous n'avez pas le droit d'accéder à cette page"
