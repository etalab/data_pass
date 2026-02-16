# language: fr

Fonctionnalité: Modification du bloc modalités pour un éditeur certifié FranceConnect
  Un demandeur doit pouvoir modifier le bloc modalités depuis le résumé
  pour un formulaire d'éditeur certifié FranceConnect. Les allers-retours entre
  « générer une nouvelle habilitation », « utiliser une existante » et
  « sans FranceConnect » doivent toujours produire un résumé cohérent.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Ouverture du bloc modalités
    Sachant que j'ai une demande API Particulier d'éditeur certifié FC en brouillon
    Quand je me rends sur le résumé de cette demande
    Et je clique sur "Modifier" dans le bloc de résumé "Les modalités d'appel de l'API"
    Alors la page contient "Comment vos usagers accèderont aux données ?"

  @javascript
  Scénario: Mode génération → enregistrement → résumé cohérent avec données FranceConnect
    Sachant que j'ai une demande API Particulier d'éditeur certifié FC utilisant une habilitation existante en brouillon
    Quand je me rends sur le résumé de cette demande
    Et je clique sur "Modifier" dans le bloc de résumé "Les modalités d'appel de l'API"
    Et je choisis "Générer automatiquement une nouvelle habilitation FranceConnect"
    Et je clique sur "Enregistrer les modifications"
    Alors la page contient "Vérifiez le récapitulatif de votre demande"
    Et il y a "Pour FranceConnect" dans le bloc de résumé "Le cadre juridique"
    Et il y a "FranceConnect" dans le bloc de résumé "Les données"

  @javascript
  Scénario: Mode existante → enregistrement → résumé cohérent sans données FranceConnect
    Sachant que j'ai une demande API Particulier d'éditeur certifié FC avec génération d'une nouvelle habilitation en brouillon
    Quand je me rends sur le résumé de cette demande
    Et je clique sur "Modifier" dans le bloc de résumé "Les modalités d'appel de l'API"
    Et je choisis "Utiliser une habilitation FranceConnect existante"
    Et je clique sur "Enregistrer les modifications"
    Alors la page contient "Vérifiez le récapitulatif de votre demande"
    Et il n'y a pas "Pour FranceConnect" dans le bloc de résumé "Le cadre juridique"
    Et il n'y a pas "FranceConnect" dans le bloc de résumé "Les données"

  @javascript
  Scénario: Passage génération → existante → enregistrement → résumé cohérent
    Sachant que j'ai une demande API Particulier d'éditeur certifié FC avec génération d'une nouvelle habilitation en brouillon
    Quand je me rends sur le résumé de cette demande
    Et je clique sur "Modifier" dans le bloc de résumé "Les modalités d'appel de l'API"
    Et je choisis "Utiliser une habilitation FranceConnect existante"
    Et je clique sur "Enregistrer les modifications"
    Alors la page contient "Vérifiez le récapitulatif de votre demande"
    Et il n'y a pas "Pour FranceConnect" dans le bloc de résumé "Le cadre juridique"
    Et il n'y a pas "FranceConnect" dans le bloc de résumé "Les données"

  @javascript
  Scénario: Passage existante → génération → enregistrement → données FranceConnect restaurées
    Sachant que j'ai une demande API Particulier d'éditeur certifié FC utilisant une habilitation existante en brouillon
    Quand je me rends sur le résumé de cette demande
    Et je clique sur "Modifier" dans le bloc de résumé "Les modalités d'appel de l'API"
    Et je choisis "Générer automatiquement une nouvelle habilitation FranceConnect"
    Et je clique sur "Enregistrer les modifications"
    Alors la page contient "Vérifiez le récapitulatif de votre demande"
    Et il y a "Pour FranceConnect" dans le bloc de résumé "Le cadre juridique"
    Et il y a "FranceConnect" dans le bloc de résumé "Les données"

  @javascript
  Scénario: Décocher FranceConnect → enregistrement → résumé cohérent sans données FranceConnect
    Sachant que j'ai une demande API Particulier d'éditeur certifié FC avec génération d'une nouvelle habilitation en brouillon
    Quand je me rends sur le résumé de cette demande
    Et je clique sur "Modifier" dans le bloc de résumé "Les modalités d'appel de l'API"
    Et je coche "Via un jeton d'accès, accompagné des paramètres usagers."
    Et je décoche "Via FranceConnect"
    Et je clique sur "Enregistrer les modifications"
    Alors la page contient "Vérifiez le récapitulatif de votre demande"
    Et il n'y a pas "Pour FranceConnect" dans le bloc de résumé "Le cadre juridique"
    Et il n'y a pas "FranceConnect" dans le bloc de résumé "Les données"

  @javascript
  Scénario: Décocher puis recocher FranceConnect → données restaurées
    Sachant que j'ai une demande API Particulier d'éditeur certifié FC avec génération d'une nouvelle habilitation en brouillon
    Quand je me rends sur le résumé de cette demande
    Et je clique sur "Modifier" dans le bloc de résumé "Les modalités d'appel de l'API"
    Et je coche "Via un jeton d'accès, accompagné des paramètres usagers."
    Et je décoche "Via FranceConnect"
    Et je clique sur "Enregistrer les modifications"
    Et je clique sur "Modifier" dans le bloc de résumé "Les modalités d'appel de l'API"
    Et je coche "Via FranceConnect"
    Et je décoche "Via un jeton d'accès, accompagné des paramètres usagers."
    Et je clique sur "Enregistrer les modifications"
    Alors la page contient "Vérifiez le récapitulatif de votre demande"
    Et il y a "Pour FranceConnect" dans le bloc de résumé "Le cadre juridique"
    Et il y a "FranceConnect" dans le bloc de résumé "Les données"

  @javascript
  Scénario: Aller-retour complet génération → existante → génération → résumé cohérent
    Sachant que j'ai une demande API Particulier d'éditeur certifié FC avec génération d'une nouvelle habilitation en brouillon
    Quand je me rends sur le résumé de cette demande
    Et je clique sur "Modifier" dans le bloc de résumé "Les modalités d'appel de l'API"
    Et je choisis "Utiliser une habilitation FranceConnect existante"
    Et je clique sur "Enregistrer les modifications"
    Et je clique sur "Modifier" dans le bloc de résumé "Les modalités d'appel de l'API"
    Et je choisis "Générer automatiquement une nouvelle habilitation FranceConnect"
    Et je clique sur "Enregistrer les modifications"
    Alors la page contient "Vérifiez le récapitulatif de votre demande"
    Et il y a "Pour FranceConnect" dans le bloc de résumé "Le cadre juridique"
    Et il y a "FranceConnect" dans le bloc de résumé "Les données"
