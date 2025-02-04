# language: fr

@javascript
Fonctionnalité: Choix du formulaire API Infinoé

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je veux remplir une demande pour "API Infinoé"

  Scénario: J’ai déjà un éditeur qui a accès au bac à sable
    Quand je choisis "Oui, j’ai un éditeur qui a déjà accès au bac à sable"
    Et que je clique sur "Demande libre avec éditeur"
    Alors la page contient "Demande libre avec éditeur"

  Scénario: Je n’ai pas d'éditeur
    Et que je choisis "Non, nous n’avons pas d’éditeur avec accès au bac à sable"
    Et que je clique sur "Demande libre (Bac à sable)"
    Alors la page contient "Demande libre (Bac à sable)"



