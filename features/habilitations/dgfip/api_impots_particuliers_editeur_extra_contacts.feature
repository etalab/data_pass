# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Impôts Particuliers avec éditeur et contact supplémentaire
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je démarre une nouvelle demande d'habilitation "API Impôt Particulier" à l'étape "Bac à sable"
    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je choisis "Via le numéro fiscal (SPI)"
    * je clique sur "Suivant"

    * je coche "Dernière année de revenu"
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je renseigne les informations du contact technique

  Scénario: Je soumets une demande d'habilitation avec contact supplémentaire valide
    * je remplis "Adresse email générique du contact technique" avec "generic@tech.com"
    * je remplis "Nom du contact supplémentaire" avec "Jean ExtraDupont"
    * je remplis "Email du contact supplémentaire" avec "hello@orga.com"
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"
    Quand je clique sur le premier "Consulter"
    Alors il y a "Jean ExtraDupont" dans le bloc de résumé "Les personnes impliquées"

