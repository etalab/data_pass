# language: fr

Fonctionnalité: Persistance des documents dans la demande d'habilitation
  Les documents ajoutés peuvent être remplacés ou supprimés.
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

  Scénario: Remplacer un document existant du projet "API Satelit Sandbox"
    * je démarre une nouvelle demande d'habilitation "API Satelit"
    * je renseigne les infos de bases du projet
    * je remplis "Maquette du projet" avec le fichier "spec/fixtures/dummy.pdf"
    * je clique sur "Suivant"
    * je clique sur "Précédent"
    Alors la page contient "dummy.pdf"

    * je remplis "Maquette du projet" avec le fichier "spec/fixtures/another_dummy.pdf"
    * je clique sur "Suivant"
    * je clique sur "Précédent"
    Alors la page contient "another_dummy.pdf"

  Règle: Gestion de la suppression de documents lors de la réouverture d'habilitation
    Contexte:
      Quand j'ai 1 demande d'habilitation "API Impôt Particulier" validée
      Et que cette demande possède une maquette du projet "dummy.pdf"
      Et que cette demande possède une maquette du projet "another_dummy.pdf"
      Et que je me rends sur mon tableau de bord demandeur habilitations
      Et que je clique sur le premier "Consulter"
      Et que je clique sur "Mettre à jour"
      Et que je clique sur "Mettre à jour l’habilitation bac à sable"
      Et que je clique sur "Modifier" dans le bloc de résumé "Mon projet"
      Alors la page contient "dummy.pdf"
      Et la page contient "another_dummy.pdf"

    @javascript
    Scénario: Soumission d'une habilitation réouverte avec suppression de document
      Et il n'y a pas de bouton "Envoyer ma demande de modification"
      Quand je supprime le document "another_dummy.pdf"
      Et que je clique sur "Enregistrer les modifications"
      Alors la page ne contient pas "another_dummy.pdf"
      Et la page contient "dummy.pdf"
      Alors il y a un bouton "Envoyer ma demande de modification"

    @javascript
    Scénario: Annulation d'une réouverture avec suppression de document dans l'étape de modification
      Quand je supprime le document "another_dummy.pdf"
      Et que je clique sur "Retour à la synthèse"
      Et que je clique sur "Annuler ma demande de modification"
      Et que je me rends sur mon tableau de bord demandeur habilitations
      Et que je clique sur le premier "Consulter"
      Alors la page contient "dummy.pdf"
      Et la page contient "another_dummy.pdf"

    @javascript @pending
    Scénario: Annulation d'une réouverture avec suppression de document après enregistrement des modifications
      Quand je supprime le document "another_dummy.pdf"
      Et que je clique sur "Enregistrer les modifications"
      Et que je clique sur "Annuler ma demande de modification"
      Et que je me rends sur mon tableau de bord demandeur habilitations
      Et que je clique sur le premier "Consulter"
      Alors la page contient "dummy.pdf"
      Et la page contient "another_dummy.pdf"
