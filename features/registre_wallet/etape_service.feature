# language: fr

Fonctionnalité: Registre wallet, étape « Le service »
  Le demandeur nomme et décrit le service qui demandera des données au wallet (DPP-208).

  Contexte:
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je remplis l’étape « L’organisation » du registre wallet

  Scénario: L’étape présente le service et son habilitation en lecture seule (CA7)
    Alors la page contient "Étape 2/2"
    Et la page contient "Quel service demandera des données au wallet ?"
    Et la page contient "Aperçu dans le wallet"
    Et la page contient "Habilitation du service"
    Et la page contient "Fournisseur de services (Service_Provider)"
    Et la page ne contient pas "Ajouter un service"

  Scénario: Le service est enregistré dans le brouillon, avec l’habilitation Service_Provider (CA1)
    Quand je décris le service "Vélocité Libre-service" avec l’identifiant "libre-service"
    Et je clique sur "Suivant"
    Alors la page ne contient pas "à corriger avant de continuer"
    Et la page contient "Vélocité Libre-service"
    Et la page contient "libre-service"
    Et la page contient "Location de vélos en libre-service dans la métropole de Lyon."
    Et la page contient "Fournisseur de services (Service_Provider)"

  Scénario: Un nom de 51 caractères garde le demandeur sur l’étape (CA2)
    Quand je décris le service "Vélocité Libre-service de la métropole de Lyon 2026" avec l’identifiant "libre-service"
    Et je clique sur "Suivant"
    Alors la page contient "Un point à corriger avant de continuer"
    Et la page contient "51/50 caractères"
    Et la page contient "Le nom du service compte 51 caractères. Raccourcissez-le à 50 caractères au plus : il s’affiche dans le wallet."

  Scénario: Un identifiant déjà utilisé par un service en cours de vérification est refusé (CA3)
    Sachant qu'un autre service de mon organisation, "en cours de vérification", utilise l’identifiant "libre-service"
    Quand je décris le service "Vélocité Libre-service" avec l’identifiant "libre-service"
    Et je clique sur "Suivant"
    Alors la page contient "Un point à corriger avant de continuer"
    Et la page contient "Un autre service de votre organisation utilise déjà cet identifiant. Choisissez-en un autre."

  Scénario: Un identifiant porté par le brouillon d’une autre personne ne bloque pas (CA9)
    Sachant qu'un autre service de mon organisation, "en brouillon", utilise l’identifiant "libre-service"
    Quand je décris le service "Vélocité Libre-service" avec l’identifiant "libre-service"
    Et je clique sur "Suivant"
    Alors la page ne contient pas "à corriger avant de continuer"
    Et la page contient "Vélocité Libre-service"

  Scénario: Une description « test » garde le demandeur sur l’étape (CA4)
    Quand je décris le service "Vélocité Libre-service" avec l’identifiant "libre-service"
    Et je remplis "Description du service" avec "test"
    Et je clique sur "Suivant"
    Alors la page contient "Un point à corriger avant de continuer"
    Et la page contient "Description du service : trop courte."

  Scénario: Un nom absent du répertoire Sirene demande un justificatif
    Quand je décris le service "Vélocité Libre-service" avec l’identifiant "libre-service" sans justificatif
    Et je clique sur "Suivant"
    Alors la page contient "Un point à corriger avant de continuer"
    Et la page contient "Justificatif du nom du service : joignez un document."
    Et la page contient "Joignez un justificatif du nom du service : le registre en a besoin pour le vérifier."
    Et la page contient "Ce nom ne correspond à aucun nom de votre organisation dans le répertoire Sirene"

  Scénario: Un nom du répertoire Sirene dispense du justificatif
    Quand je décris le service "Mairie" avec l’identifiant "mairie" sans justificatif
    Et je clique sur "Enregistrer"
    Alors la page contient "Ce nom correspond à l’enseigne de votre organisation dans le répertoire Sirene : vous n’avez pas de justificatif à joindre."
    Et la page ne contient pas "Justificatif du nom du service"
    Quand je clique sur "Suivant"
    Alors la page ne contient pas "à corriger avant de continuer"

  Scénario: Sans JavaScript, l’identifiant vide est proposé à partir du nom (RG3)
    Quand je décris le service "Vélo Été" avec l’identifiant ""
    Et je clique sur "Enregistrer"
    Alors le champ "Identifiant du service" contient "velo-ete"

  @javascript
  Scénario: L’identifiant suit le nom tant que le demandeur ne l’a pas modifié (CA8)
    Quand je remplis "Nom du service" avec "Vélo Été"
    Alors le champ "Identifiant du service" contient "velo-ete"
    Et la page contient "8/50 caractères"
    Quand je remplis "Identifiant du service" avec "mon-service"
    Et je remplis "Nom du service" avec "Vélo Été Lyon"
    Alors le champ "Identifiant du service" contient "mon-service"
    Quand je remplis "Identifiant du service" avec ""
    Alors le champ "Identifiant du service" contient "velo-ete-lyon"

  @javascript
  Scénario: Le navigateur propose le même identifiant que le serveur pour les lettres sans accent décomposable (RG3)
    Quand je remplis "Nom du service" avec "Straße Øst"
    Alors le champ "Identifiant du service" contient "strasse-ost"

  @javascript
  Scénario: Le format de l’identifiant est contrôlé dès que le demandeur quitte le champ (RG6)
    Quand je remplis "Identifiant du service" avec "Libre_Service"
    Et je quitte le champ "Identifiant du service"
    Alors la page contient "L’identifiant ne peut contenir que des lettres minuscules sans accent, des chiffres et des tirets"

  @javascript
  Scénario: Le justificatif du nom suit la saisie du nom
    Alors la page ne contient pas "Justificatif du nom du service"
    Quand je remplis "Nom du service" avec "Commune de Clamart"
    Alors la page contient "Ce nom correspond à la dénomination de votre organisation dans le répertoire Sirene"
    Et la page ne contient pas "Justificatif du nom du service"
    Quand je remplis "Nom du service" avec "Portail famille de Clamart"
    Alors la page contient "Justificatif du nom du service"
    Et la page ne contient pas "Ce nom correspond"
