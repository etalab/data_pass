# language: fr

Fonctionnalité: Instruction: la révocation d'une habilitation APIP cascade vers l'habilitation FC liée
  Quand une habilitation API Particulier avec modalité FranceConnect est révoquée,
  l'habilitation FranceConnect auto-générée doit aussi être révoquée.

  @DisableBullet
  Scénario: La révocation d'une habilitation APIP révoque aussi l'habilitation FC liée
    Sachant que je suis un instructeur "API Particulier"
    Et que je me connecte
    Et qu'il y a une demande API Particulier avec champs FranceConnect intégrés validée
    Et qu'il y a 2 habilitations pour cette demande
    Quand je me rends sur l'habilitation APIP de la demande
    Et je clique sur "Révoquer"
    Et que je remplis "Indiquez les motifs de révocation" avec "Motif de révocation cascade"
    Et que je clique sur "Révoquer l'habilitation"
    Alors il y a un message de succès contenant "a été révoquée"
    Quand je me rends sur cette demande d'habilitation
    Et que je clique sur "Toutes les habilitations"
    Alors les 2 habilitations de la demande sont révoquées
