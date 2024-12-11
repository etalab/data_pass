# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Impôt Particulier de production depuis une demande de Bac à sable validée
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Et que j'ai 1 demande d'habilitation "API Impôt Particulier" à l'étape "Bac à sable" validée
    Et que je me rends sur mon tableau de bord

  Scénario: Je soumets une demande d'habilitation valide
    Quand je clique sur "Démarrer ma demande d’habilitation en production"
    Et que je clique sur "Débuter ma demande"

    * je renseigne la recette fonctionnelle
    * je clique sur "Suivant"

    * je renseigne l'homologation de sécurité
    * je clique sur "Suivant"

    * je renseigne la volumétrie pour "API Impôt Particulier"
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"
