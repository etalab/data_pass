# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Impôts Particuliers avec éditeur et verification de la compatibilité des règles de scopes

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

    Quand je veux remplir une demande pour "API Impôt Particulier" via le formulaire "API Impôt Particulier avec éditeur"
    Et que je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

  Scénario: Je soumets une demande d'habilitation sans scopes d'années de revenue cochés.
    * je coche "Situation de famille (marié, pacsé, célibataire, veuf divorcé)"
    * je clique sur "Suivant"

    Alors la page contient "Une erreur est survenue lors de la sauvegarde de la demande d'habilitation"
    Et la page contient "Les données sont invalides : Vous devez cocher au moins une année de revenus souhaitée avant de continuer"

  Scénario: Je soumets une demande d'habilitation avec 2 scopes d'annéees de revenue cochés incompatible.
    * je coche "Dernière année de revenu"
    * je coche "Avant-dernière année de revenu, si la dernière année de revenu est indisponible"
    * je clique sur "Suivant"

    Alors la page contient "Une erreur est survenue lors de la sauvegarde de la demande d'habilitation"
    Et la page contient "Les données sont invalides : Vous ne pouvez pas sélectionner la donnée 'avant dernière année de revenu, si la dernière année de revenu est indisponible' avec d'autres années de revenus"

  Scénario: Je soumets une demande d'habilitation avec 2 scopes incompatibles.
    * je coche "Dernière année de revenu"
    * je coche "Données fiscales au 31/12 en cas de décès d'un contribuable marié ou pacsé"
    * je coche "Versement épargne retraite"
    * je clique sur "Suivant"

    Alors la page contient "Une erreur est survenue lors de la sauvegarde de la demande d'habilitation"
    Et la page contient "Les données sont invalides : Des données incompatibles entre elles ont été cochées. Pour connaître les modalités d’appel et de réponse de l’API Impôt particulier ainsi que les données proposées, vous pouvez consulter le guide de présentation de cette API dans la rubrique « Les données nécessaires > Comment choisir les données"
