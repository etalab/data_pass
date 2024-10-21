# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Impôts Particuliers avec éditeur
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je soumets une demande d'habilitation valide
    Quand je démarre une nouvelle demande d'habilitation "API Impôt Particulier"
   
    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je coche "Dernière année de revenu"
    * je clique sur "Suivant"

    * Je renseigne l'homologation de sécurité
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je renseigne les informations du contact technique
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation dont la date de fin d'homologation est inférieure à la date de début
    Quand je démarre une nouvelle demande d'habilitation "API Impôt Particulier"
   
    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je coche "Dernière année de revenu"
    * je clique sur "Suivant"

    * je remplis "Nom de l’autorité d’homologation ou du signataire du questionnaire de sécurité" avec "Article 42"
    * je remplis "Fonction de l’autorité d’homologation ou du signataire du questionnaire de sécurité" avec "Représentant de l'autorité d'homologation des joints d'étanchéité de conduits d'évacuation de climatiseurs de morgue"
    * je remplis "La décision d’homologation ou le questionnaire de sécurité" avec le fichier "spec/fixtures/dummy.pdf"
    * je remplis "Date de début d’homologation ou de signature du questionnaire de sécurité" avec "2025-05-22"
    * je remplis "Date de fin d’homologation" avec "2024-01-01"
    * je clique sur "Suivant"
    Alors la page contient "Une erreur est survenue lors de la sauvegarde de la demande d'habilitation"
    Et la page contient "Date de fin d’homologation doit être supérieure à la date de début"