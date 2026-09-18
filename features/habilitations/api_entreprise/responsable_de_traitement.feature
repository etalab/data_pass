# language: fr

Fonctionnalité: API Entreprise : plus de responsable de traitement
  Le responsable de traitement n’est plus demandé sur les habilitations API Entreprise.

  Scénario: Le formulaire éditeur ne demande plus de responsable de traitement
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Conformité titulaires de marchés" de l'éditeur "Approval"
    Et que je clique sur "Débuter ma demande"
    Alors la page ne contient pas "Responsable de traitement"
    Et la page contient "Délégué à la protection des données"

  Scénario: Le formulaire en plusieurs étapes ne demande plus de responsable de traitement
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je me rends sur une demande d'habilitation "Solution Portail des aides" en brouillon
    Alors la page ne contient pas "Responsable de traitement"
