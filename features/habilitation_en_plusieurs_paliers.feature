# language: fr

Fonctionnalité: Interactions avec des habilitations en plusieurs paliers (bac à sable/production)
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je peux démarrer une habilitation de production depuis une habilitation bac à sable validée sur le tableau de bord
    Quand j'ai 1 demande d'habilitation "API Impôt Particulier" à l'étape "Bac à sable" validée
    Et que je me rends sur mon tableau de bord habilitations
    Alors il y a un bouton "Démarrer ma demande d’habilitation en production"

  Scénario: Je peux démarrer une demande de production depuis une habilitation bac à sable active
    Quand j'ai 1 demande d'habilitation "API Impôt Particulier" à l'étape "Bac à sable" validée
    Et que je me rends sur mon tableau de bord habilitations
    Et que je clique sur "Consulter"
    Alors il y a un bouton "Démarrer ma demande d’habilitation en production"

  Scénario: Je ne peux pas démarrer une habilitation de production depuis une habilitation bac à sable en cours d'instruction sur le tableau de bord
    Quand j'ai 1 demande d'habilitation "API Impôt Particulier" à l'étape "Bac à sable" en attente
    Et que je vais sur la page du tableau de bord
    Alors il n'y a pas de bouton "Démarrer ma demande d’habilitation en production"

  Scénario: Il n'y a pas de message d'erreur contenant "Vous ne pouvez pas créer de nouvelle habilitation" (non-régression test)
    Quand j'ai 1 demande d'habilitation "API Impôt Particulier" à l'étape "Bac à sable" validée
    Et que j'ai 1 demande d'habilitation "API Impôt Particulier" à l'étape "Production" validée
    Et que je me rends sur mon tableau de bord habilitations
    Et que je clique sur "Démarrer ma demande d’habilitation en production"
    Alors la page ne contient pas "Vous ne pouvez pas créer de nouvelle habilitation"

  Scénario: Je peux démarrer une habilitation de production depuis une habilitation bac à sable
    Quand j'ai 1 demande d'habilitation "API Impôt Particulier" à l'étape "Bac à sable" validée
    Et que je me rends sur mon tableau de bord habilitations
    Et que je clique sur "Démarrer ma demande d’habilitation en production"
    Et que je clique sur "Débuter ma demande"
    Et que je vais sur la page du tableau de bord
    Alors il n'y a pas de bouton "Démarrer ma demande d’habilitation en production"

  Scénario: Je peux annuler une demande d'habilitation de production si je ne l'ai pas encore soumise
    Quand j'ai 1 demande d'habilitation "API Impôt Particulier" à l'étape "Bac à sable" validée
    Et que je me rends sur mon tableau de bord habilitations
    Et que je clique sur "Démarrer ma demande d’habilitation en production"
    Et que je clique sur "Débuter ma demande"
    Et que je clique sur "Annuler la demande de production"
    Et que je clique sur "Confirmer"
    Alors il y a un message de succès contenant "Votre demande d'habilitation en production a été annulée"
    Et il y a un bouton "Démarrer ma demande d’habilitation en production"
    Et il y a un badge "Bac à sable"

  Scénario: Il y a un badge sandbox lors du démarrage d'une habilitation de bac à sable
    Quand je veux remplir une demande pour "API Impôt Particulier" via le formulaire "Demande libre (Bac à sable)" à l'étape "Bac à sable"
    Et que je clique sur "Débuter ma demande"
    Alors il y a un badge "Bac à sable"

  Scénario: Il y a un badge production lors du démarrage d'une habilitation de production depuis une habilitation bac à sable
    Quand j'ai 1 demande d'habilitation "API Impôt Particulier" à l'étape "Bac à sable" validée
    Et que je me rends sur mon tableau de bord habilitations
    Et que je clique sur "Démarrer ma demande d’habilitation en production"
    Et que je clique sur "Débuter ma demande"
    Alors il y a un badge "Production"

  Scénario: Je soumets une habilitation de production depuis une habilitation bac à sable
    Quand j'ai 1 demande d'habilitation "API Impôt Particulier" à l'étape "Bac à sable" validée
    Et que je me rends sur mon tableau de bord habilitations
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
    Et il y a un badge "Production"
    Et il y a un badge "En cours"
