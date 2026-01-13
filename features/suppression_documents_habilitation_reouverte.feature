# language: fr

Fonctionnalité: Suppression de documents dans une habilitation réouverte
  Lorsqu'un demandeur réouvre une habilitation validée pour la mettre à jour,
  il peut supprimer des documents. Ces suppressions doivent être gérées correctement
  selon que le demandeur soumet ou annule sa demande de modification.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Et que j'ai 1 demande d'habilitation "API Impôt Particulier" validée
    Et que cette demande possède une maquette du projet "dummy.pdf"
    Et que je me rends sur mon tableau de bord demandeur habilitations
    Et que je clique sur le premier "Consulter"
    Et que je clique sur "Mettre à jour"
    Et que je clique sur "Mettre à jour l'habilitation bac à sable"
    Et il n'y a pas de bouton "Envoyer ma demande de modification"
    Quand je clique sur "Modifier" dans le bloc de résumé "Mon projet"
    Alors la page contient "dummy.pdf"
    Quand je supprime le document "dummy.pdf"
    Alors la page ne contient pas "dummy.pdf"

  @javascript
  Scénario: Soumission avec suppression de document
    Et que je clique sur "Enregistrer les modifications"
    Alors la page ne contient pas "dummy.pdf"
    Alors il y a un bouton "Envoyer ma demande de modification"
    Et que je clique sur "Envoyer ma demande de modification"
    Alors il y a un message de succès contenant "soumise avec succès"
    Et il y a un badge "En cours"

  @javascript
  Scénario: Retour à la synthèse sans enregistrer la suppression
    Et que je clique sur "Retour à la synthèse"
    Alors la page contient "dummy.pdf"

  @javascript
  Scénario: Annulation de la demande de modification après suppression
    Et que je clique sur "Enregistrer les modifications"
    Alors la page ne contient pas "dummy.pdf"
    Et que je clique sur "Annuler ma demande de modification"
    Et que je clique sur "Annuler ma demande de modification"
    Alors la page contient "Demandes et habilitation"
    Et que je clique sur le premier "Consulter"
    Alors la page contient "dummy.pdf"