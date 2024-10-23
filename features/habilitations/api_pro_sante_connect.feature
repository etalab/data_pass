# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Pro Santé Connect

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Et je démarre une nouvelle demande d'habilitation "API Pro Santé Connect"

  Scénario: Je soumets une demande d'habilitation valide
    Quand je démarre une nouvelle demande d'habilitation "API Pro Santé Connect"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je remplis "Précisez la nature et les références du texte vous autorisant à traiter les données" avec "Arrêté du 24 mars 2021"
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/loda/id/JORFTEXT000043290292"
    * je clique sur "Suivant"

    * je coche "Identifiant national"
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je renseigne les informations du contact technique
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"
