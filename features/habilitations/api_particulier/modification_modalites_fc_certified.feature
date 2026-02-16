# language: fr

Fonctionnalité: Modification du bloc modalités pour un éditeur certifié FranceConnect
  Un demandeur doit pouvoir modifier le bloc modalités depuis le résumé
  pour un formulaire d'éditeur certifié FranceConnect.

  Scénario: Modification du bloc modalités depuis le résumé
    Sachant que je suis un demandeur
    Et que je me connecte
    Et que j'ai une demande API Particulier d'éditeur certifié FC en brouillon
    Quand je me rends sur le résumé de cette demande
    Et je clique sur "Modifier" dans le bloc de résumé "Les modalités d'appel de l'API"
    Alors la page contient "Comment vos usagers accèderont aux données ?"
