# language: fr

Fonctionnalité: Instruction: révocation individuelle d'une habilitation
  Un instructeur peut révoquer une habilitation individuelle depuis sa page,
  sans affecter les habilitations sœurs de la même demande.

  Contexte:
    Sachant que je suis un instructeur "API scolarité de l’élève"
    Et que je me connecte

  @AvecCourriels
  @DisableBullet
  Scénario: Je révoque une habilitation individuelle depuis sa page
    Sachant qu'il y a 1 habilitation "API scolarité de l’élève" active
    Et qu'une seconde habilitation active existe sur la même demande
    Quand je me rends sur la première habilitation validée
    Et je clique sur "Révoquer"
    Et que je remplis "Indiquez les motifs de révocation" avec "Motif de test"
    Et que je clique sur "Révoquer l'habilitation"
    Alors il y a un message de succès contenant "a été révoquée"
    Et la première habilitation de la demande est révoquée
    Et la seconde habilitation de la demande est active
    Et la demande est toujours validée
    Et un email est envoyé contenant "Motif de test"

  @DisableBullet
  Scénario: La révocation de la dernière habilitation active entraîne la révocation de la demande
    Sachant qu'il y a 1 habilitation "API scolarité de l’élève" active
    Quand je me rends sur la première habilitation validée
    Et je clique sur "Révoquer"
    Et que je remplis "Indiquez les motifs de révocation" avec "Motif de test"
    Et que je clique sur "Révoquer l'habilitation"
    Alors il y a un message de succès contenant "a été révoquée"
    Et la demande est révoquée
