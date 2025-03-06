# language: fr

@javascript
Fonctionnalité: Choix du formulaire API SFiP

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je veux remplir une demande pour "API Courtier fonctionnel SFiP"

  Scénario: J’ai déjà un éditeur qui a accès au bac à sable
    Quand je choisis "Oui, j’ai un éditeur qui a finalisé et validé ses développements en environnement de bac à sable"
    Alors la page contient "Demande libre avec éditeur"

  Scénario: Je n’ai pas d'éditeur
    Et que je choisis "Non, nous n’avons pas d’éditeur avec accès au bac à sable"
    Et que je clique sur "Demande libre (Bac à sable)"
    Alors la page contient "Demande libre (Bac à sable)"



