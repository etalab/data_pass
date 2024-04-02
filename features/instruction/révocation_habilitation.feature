# language: fr

Fonctionnalité: Instruction: révocation d'habilitation
  Un instructeur peut révoquer une habilitation.

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte

  @AvecCourriels
  @DisableBullet
  Scénario: Je révoque une habilitation avec un message valide
    Quand je me rends sur une habilitation "API Entreprise" validée
    Et je clique sur "Révoquer"
    Et que je remplis "Raison de la révocation" avec "Une nouvelle demande a été validée"
    Et que je clique sur "Révoquer l'habilitation"
    Alors je suis sur la page "Liste des demandes en cours"
    Et je vois 1 habilitation "API Entreprise" révoquée
    Et un email est envoyé contenant "Une nouvelle demande a été validée"
    Et il y a un message de succès contenant "a été révoquée"
