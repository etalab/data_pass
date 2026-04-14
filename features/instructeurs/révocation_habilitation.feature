# language: fr

Fonctionnalité: Instruction: révocation d'habilitation
  Un instructeur peut révoquer une habilitation depuis sa page.

  Contexte:
    Sachant que je suis un instructeur "API scolarité de l’élève"
    Et que je me connecte

  @AvecCourriels
  @DisableBullet
  Scénario: Je révoque une habilitation avec un message valide
    Quand je me rends sur une demande d'habilitation "API scolarité de l’élève" validée
    Et que je me rends sur l'habilitation validée
    Et je clique sur "Révoquer"
    Et que je remplis "Indiquez les motifs de révocation" avec "Une nouvelle demande a été validée"
    Et que je clique sur "Révoquer l'habilitation"
    Alors il y a un message de succès contenant "a été révoquée"
    Et un email est envoyé contenant "Une nouvelle demande a été validée"
