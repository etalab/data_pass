# language: fr

Fonctionnalité: Persistance des documents dans la demande d'habilitation
  Les documents ajoutés dans la ou les sections doivent persister
  lorsqu'on navigue entre les étapes du formulaire.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    * je démarre une nouvelle demande d'habilitation "API Ingres"
    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"
    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"
    * je remplis "Précisez la nature et les références du texte vous autorisant à traiter les données" avec "Article 42"

  Scénario: Ajout de deux documents PDF dans le cadre juridique et vérification de leur persistance
    Quand je joins 2 documents au cadre juridique du projet "API Ingres"
    * je clique sur "Suivant"
    Et la page contient 'Quelles sont les personnes impliquées ?'
    * je clique sur "Précédent"
    Alors la page contient "dummy.pdf"
    Et la page contient "another_dummy.pdf"

  @javascript
  Scénario: Suppression d'un ou plusieurs documents PDF dans le cadre juridique
    Quand je joins 2 documents au cadre juridique du projet "API Ingres"
    * je clique sur "Suivant"
    Et la page contient 'Quelles sont les personnes impliquées ?'
    * je clique sur "Précédent"

    Alors la page contient "dummy.pdf"
    Et la page contient "another_dummy.pdf"
    Quand je supprime le document "another_dummy.pdf"
    Alors la page ne contient pas "another_dummy.pdf"
    Et la page contient "dummy.pdf"
