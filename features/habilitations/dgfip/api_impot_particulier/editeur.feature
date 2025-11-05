# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Impôt Particulier avec éditeur
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

    Quand je veux remplir une demande pour "API Impôt Particulier" via le formulaire "Demande libre avec éditeur"
    Et que je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je choisis "Via le numéro fiscal (SPI)"
    * je clique sur "Suivant"

    * je coche "Dernière année de revenu (N-1)"
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je renseigne les informations du contact technique
    * je clique sur "Suivant"

  Scénario: Je soumets une demande d'habilitation valide
    * je renseigne l'homologation de sécurité
    * je clique sur "Suivant"

    * je renseigne la volumétrie
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je coche "J’atteste que mon organisation devra déclarer à la DGFiP l’accomplissement des formalités en matière de protection des données à caractère personnel et qu’elle veillera à procéder à l’homologation de sécurité de son projet."
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation dont la date de fin d'homologation est inférieure à la date de début
    * je remplis "Nom de l’autorité d’homologation ou du signataire du questionnaire de sécurité" avec "Article 42"
    * je remplis "Fonction de l’autorité d’homologation ou du signataire du questionnaire de sécurité" avec "Représentant de l'autorité d'homologation des joints d'étanchéité de conduits d'évacuation de climatiseurs de morgue"
    * je remplis "La décision d’homologation ou le questionnaire de sécurité" avec le fichier "spec/fixtures/dummy.pdf"
    * je remplis "Date de début d’homologation ou de signature du questionnaire de sécurité" avec "2025-05-22"
    * je remplis "Date de fin d’homologation" avec "2024-01-01"
    * je clique sur "Suivant"

    Alors la page contient "Une erreur est survenue lors de la sauvegarde de la demande d'habilitation"
    Et la page contient "Date de fin d’homologation doit être supérieure à la date de début"

  Scénario: Je soumets une demande d'habilitation avec une haute volumétrie et aucune justification
    * je renseigne l'homologation de sécurité
    * je clique sur "Suivant"

    * je sélectionne "200 appels / minute" pour "Quelle limitation de débit souhaitez-vous pour votre téléservice ?"
    * je clique sur "Suivant"

    Alors la page contient "Une erreur est survenue lors de la sauvegarde de la demande d'habilitation"
    Et la page contient "La justification de la limitation de débit doit être rempli(e)"

  Scénario: Je soumets une demande d'habilitation avec une haute volumétrie et une justification
    * je renseigne l'homologation de sécurité
    * je clique sur "Suivant"

    * je sélectionne "200 appels / minute" pour "Quelle limitation de débit souhaitez-vous pour votre téléservice ?"
    * je remplis "Pour quels motifs souhaitez-vous un débit plus grand que le minimum ? (volumétrie par mois et par jour, pics d'activité, période de disponibilité du téléservice...)" avec "Une super justification"
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je coche "J’atteste que mon organisation devra déclarer à la DGFiP l’accomplissement des formalités en matière de protection des données à caractère personnel et qu’elle veillera à procéder à l’homologation de sécurité de son projet."
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"
