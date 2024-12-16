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

    * je choisis "Via le numéro fiscal (SPI)"
    * je clique sur "Suivant"

  Scénario: J'ouvre la documentation d'un groupe de scope
    Et la page contient "documentation"
    Et la page contient "En cochant la case Avant-dernière année de revenu, si la dernière année de revenu est indisponible"

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
    Et la page contient "Les données sont invalides : Des données incompatibles entre elles ont été cochées"

  @javascript
  Scénario: Je soumets une demande d'habilitation sans scopes mais je joins un fichier d'expression de besoin spécifique.
    * je coche "Oui, j’ai une expression de besoin spécifique"
    * je remplis "Ajoutez le fichier d’expression de vos besoins" avec le fichier "spec/fixtures/dummy.xlsx"
    * je clique sur "Suivant"

    Alors la page contient "Les personnes impliquées"

  Scénario: Je soumets une demande d'habilitation avec un scope en cochant le fichier de besoins spécifiques mais en oubliant de joindre le fichier.
    * je coche "Dernière année de revenu"
    * je coche "Oui, j’ai une expression de besoin spécifique"
    * je clique sur "Suivant"

    Alors la page contient "Une erreur est survenue lors de la sauvegarde de la demande d'habilitation"
    Et la page contient "Document de l'expression de besoin spécifique est manquant : vous devez ajoutez un fichier avant de passer à l’étape suivante"
