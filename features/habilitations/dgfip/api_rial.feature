# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Rial
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je soumets une demande d'habilitation valide à l'étape Bac à sable
    * je démarre une nouvelle demande d'habilitation "API RIAL (Répertoire Inter-Administratif des Locaux)" à l'étape "Bac à sable"
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

    * je coche "J’atteste que mon organisation devra déclarer à la DGFiP l’accomplissement des formalités en matière de protection des données à caractère personnel et qu’elle veillera à procéder à l’homologation de sécurité de son projet."

    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation valide à l'étape Production
    Quand j'ai 1 demande d'habilitation "API RIAL (Répertoire Inter-Administratif des Locaux)" à l'étape "Bac à sable" validée
    Et que je me rends sur mon tableau de bord demandeur habilitations
    Et je clique sur "Démarrer ma demande d’habilitation en production"
    Et que je clique sur "Débuter ma demande"

    * je renseigne la recette fonctionnelle
    * je clique sur "Suivant"

    * je renseigne l'homologation de sécurité
    * je clique sur "Suivant"

    * je renseigne la volumétrie
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"
