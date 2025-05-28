# language: fr

Fonctionnalité: Persistance des documents dans la demande d'habilitation
Les documents ajoutés peuvent être remplacés ou supprimés

  Scénario: Remplacer un document existant du projet "API Satelit Sandbox"
    Sachant que je suis un demandeur
    Et que je me connecte
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
