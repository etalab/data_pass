# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API INFINOE (Production)
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je soumets une demande d'habilitation valide
    Quand j'ai 1 demande d'habilitation "API INFINOE (Production)" en brouillon
    Et que je me rends sur mon tableau de bord
    Et que je clique sur le dernier "Consulter"

    * je coche "J'atteste avoir réalisé une recette fonctionnelle et qualifié mon téléservice."
    * je remplis "Nom de l'autorité d'homologation" avec "Autorité de homologation"
    * je remplis "Fonction de l'autorité d'homologation" avec "Fonction"
    * je remplis "Date de début de l'homologation" avec "02/01/2018"
    * je remplis "Date de fin de l'homologation" avec "01/01/2042"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Accueil"
