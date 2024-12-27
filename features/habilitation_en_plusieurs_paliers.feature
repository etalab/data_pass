# language: fr

Fonctionnalité: Interactions avec des habilitations en plusieurs paliers (bac à sable/production)
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je peux démarrer une habilitation de production depuis une habilitation bac à sable validée sur le tableau de bord
    Quand j'ai 1 demande d'habilitation "API Impôt Particulier" à l'étape "Bac à sable" validée
    Et que je vais sur la page du tableau de bord
    Alors il y a un bouton "Démarrer ma demande d’habilitation en production"

  Scénario: Je peux démarrer une habilitation de production depuis une habilitation bac à sable validée sur sa page de résumé
    Quand j'ai 1 demande d'habilitation "API Impôt Particulier" à l'étape "Bac à sable" validée
    Et que je vais sur la page du tableau de bord
    Et que je clique sur "Consulter"
    Alors il y a un bouton "Démarrer ma demande d’habilitation en production"

  Scénario: Je ne peux pas démarrer une habilitation de production depuis une habilitation bac à sable en cours d'instruction sur le tableau de bord
    Quand j'ai 1 demande d'habilitation "API Impôt Particulier" à l'étape "Bac à sable" en attente
    Et que je vais sur la page du tableau de bord
    Alors il n'y a pas de bouton "Démarrer ma demande d’habilitation en production"

  Scénario: Je peux démarrer une habilitation de production depuis une habilitation bac à sable
    Quand j'ai 1 demande d'habilitation "API Impôt Particulier" à l'étape "Bac à sable" validée
    Et que je vais sur la page du tableau de bord
    Et que je clique sur "Démarrer ma demande d’habilitation en production"
    Et que je clique sur "Débuter ma demande"
    Et que je vais sur la page du tableau de bord
    Alors il n'y a pas de bouton "Démarrer ma demande d’habilitation en production"

  Scénario: Il y a un badge sandbox lors du démarrage d'une habilitation de bac à sable
    Quand je veux remplir une demande pour API Impot Particulier via le formulaire "Demande libre (Bac à sable)" en bac à sable
    Et que je clique sur "Débuter ma demande"
    Alors il y a un badge "Bac à sable"

  Scénario: Il y a un badge production lors du démarrage d'une habilitation de production depuis une habilitation bac à sable
    Quand j'ai 1 demande d'habilitation "API Impôt Particulier" à l'étape "Bac à sable" validée
    Et que je vais sur la page du tableau de bord
    Et que je clique sur "Démarrer ma demande d’habilitation en production"
    Et que je clique sur "Débuter ma demande"
    Alors il y a un badge "Production"

  Scénario: Je soumets une habilitation de production depuis une habilitation bac à sable
    Quand j'ai 1 demande d'habilitation "API Impôt Particulier" à l'étape "Bac à sable" validée
    Et que je vais sur la page du tableau de bord
    Et que je clique sur "Démarrer ma demande d’habilitation en production"
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
