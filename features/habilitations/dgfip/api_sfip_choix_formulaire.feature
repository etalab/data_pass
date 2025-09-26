# language: fr

@javascript
Fonctionnalité: Choix du formulaire API SFiP

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je veux remplir une demande pour "API Courtier fonctionnel SFiP"

  Scénario: Je veux sélectionner un formulaire API SFiP avec un éditeur ayant déjà un accès au bac à sable
    Quand je choisis "Les données fiscales (API Impôt Particulier)"
    Alors la page contient "Travaillez-vous avec un éditeur qui a finalisé et validé ses développements en environnement de bac à sable de cette API ?"
    Et que je choisis "Oui, j’ai un éditeur qui a finalisé et validé ses développements en bac à sable"
    Alors la page contient "Demande libre avec éditeur"

  Scénario: Je n’ai pas d'éditeur
    Quand je choisis "Les données fiscales (API Impôt Particulier)"
    Alors la page contient "Travaillez-vous avec un éditeur qui a finalisé et validé ses développements en environnement de bac à sable de cette API ?"
    Et que je choisis "Non, nous n’avons pas d’éditeur qui a finalisé et validé ses développements en bac à sable"
    Et que je clique sur "Demande libre (Bac à sable)"
    Alors la page contient "Demande libre (Bac à sable)"

  Scénario: Je veux sélectionner un formulaire API SFiP R2P avec un éditeur ayant déjà un accès au bac à sable
    Quand je choisis "Les données relatives à la recherche de personnes physiques (API SFiP R2P)"
    Alors la page contient "Travaillez-vous avec un éditeur qui a finalisé et validé ses développements en environnement de bac à sable de cette API ?"
    Et que je choisis "Oui, j’ai un éditeur qui a finalisé et validé ses développements en bac à sable"
    Alors la page contient "Demande libre avec éditeur"

  Scénario: Je n’ai pas d'éditeur
    Quand je choisis "Les données relatives à la recherche de personnes physiques (API SFiP R2P)"
    Alors la page contient "Travaillez-vous avec un éditeur qui a finalisé et validé ses développements en environnement de bac à sable de cette API ?"
    Et que je choisis "Non, nous n’avons pas d’éditeur qui a finalisé et validé ses développements en bac à sable"
    Et que je clique sur "Demande libre (Bac à sable)"
    Alors la page contient "Demande libre (Bac à sable)"



