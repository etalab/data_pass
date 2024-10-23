# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation L'Annuaires des Entreprises
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je soumets une demande d'habilitation valide
    * je démarre une nouvelle demande d'habilitation "L'Annuaires des Entreprises"
    * je renseigne les infos de bases du projet
    * je renseigne le cadre légal
    * je coche "Scope 1"
    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"
    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"
