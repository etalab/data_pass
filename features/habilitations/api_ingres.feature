# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Ingres
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je soumets une demande d'habilitation valide
    * je démarre une nouvelle demande d'habilitation "API Ingres"
    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je renseigne les informations du contact technique
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"
