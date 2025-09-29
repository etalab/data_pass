# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation Espace agent de l'Annuaire des Entreprises
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je soumets une demande d'habilitation pour un cas d'usage
    * je veux remplir une demande pour "Espace agent de l'Annuaire des Entreprises" via le formulaire "<Cas d'usage>"
    * je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je coche "Effectifs annuels"
    * je clique sur "Suivant"

    * j'adhère aux conditions générales

    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Cas d'usage                                                                |
      | Marchés publics                                                            |
      | Aides publiques                                                            |
      | Subventions de fonctionnement des associations                             |
      | Lutte contre la fraude                                                     |
      | Demande libre                                                              |

  Scénario: Je soumets une demande d'habilitation pour un cas d'usage où les scopes sont fixés en avance
    * je veux remplir une demande pour "Espace agent de l'Annuaire des Entreprises" via le formulaire "<Cas d'usage>"
    * je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * j'adhère aux conditions générales

    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Cas d'usage                                                                |
      | Traitement des aides financières collectives allouées aux partenaires CAF  |

