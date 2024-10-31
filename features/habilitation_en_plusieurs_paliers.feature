# language: fr

Fonctionnalité: Interactions avec des habilitations en plusieurs paliers (bac à sable/production)
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je peux démarrer une habilitation de production depuis une habilitation bac à sable validée
    Quand j'ai 1 demande d'habilitation "API Impôt Particulier - Bac à sable" validée
    Et que je vais sur la page du tableau de bord
    Alors il y a un bouton "Démarrer ma demande d'habilitation en production"

  Scénario: Je ne peux pas démarrer une habilitation de production depuis une habilitation bac à sable en cours d'instruction
    Quand j'ai 1 demande d'habilitation "API Impôt Particulier - Bac à sable" en attente
    Et que je vais sur la page du tableau de bord
    Alors il n'y a pas de bouton "Démarrer ma demande d'habilitation en production"

