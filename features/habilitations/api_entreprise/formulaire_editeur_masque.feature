# language: fr

Fonctionnalité: Formulaire éditeur d’API Entreprise masqué
  Les éditeurs sont orientés vers le questionnaire de qualification, le formulaire
  éditeur n’est plus proposé mais les demandes existantes restent accessibles.

  Scénario: Le formulaire éditeur n’est plus démarrable par lien direct
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je vais sur la page formulaires/api-entreprise-editeur/demande/nouveau
    Alors la page ne contient pas "Formulaire spécifique aux éditeurs de logiciels"
    Et je suis sur la page "Demander une habilitation à : API Entreprise"

  Scénario: Un lien direct vers le formulaire éditeur ramène un visiteur non connecté vers l’arbre d’éligibilité
    Quand je vais sur la page formulaires/api-entreprise-editeur/demande/nouveau
    Alors la page contient "Êtes-vous :"

  Scénario: La première page du formulaire éditeur n’est pas affichée par lien direct
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je vais sur la page formulaires/api-entreprise-editeur/demande/commencer
    Alors la page ne contient pas "Formulaire spécifique aux éditeurs de logiciels"
    Et il y a un message d'erreur contenant "Vous n'avez pas le droit d'accéder à cette page"
