# language: fr

Fonctionnalité: Bandeau d’éligibilité à l’introduction du formulaire
  En tant que demandeur, à l’ouverture d’un formulaire, je vois si mon
  organisation semble éligible afin d’être orienté avant de déposer ma demande.

  Scénario: Une organisation éligible voit l’approbation automatique et les étapes
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je veux remplir une demande pour "Aide financière"
    Alors la page contient "approuvée automatiquement"
    Et la page contient "Les étapes de votre formulaire"

  Scénario: Une organisation inéligible est bloquée et orientée vers le fournisseur
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je veux remplir une demande pour "Aide financière"
    Alors la page contient "ne semble pas éligible"
    Et la page contient "Contacter le fournisseur"
    Et la page ne contient pas "Les étapes de votre formulaire"
    Et je peux voir le bouton "Débuter ma demande" grisé et désactivé
