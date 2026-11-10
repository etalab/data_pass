# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation Signalements impayés de loyer (CNAF)
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je vois l'introduction du formulaire et l'adresse de support de la CNAF
    Quand j'ouvre le lien direct du formulaire de la démarche "Signalements impayés de loyer"
    Alors la page contient "Signalements impayés de loyer"
    Et la page contient "Caisse nationale des allocations familiales"
    Et la page contient "production_numerique_echanges@cnaf.fr"

  Scénario: Le formulaire n'apparaît pas dans le catalogue
    Quand je vais sur la page des demandes
    Alors la page ne contient pas "Signalements impayés de loyer"

  Scénario: Je soumets une demande d'habilitation valide
    Quand j'ouvre le lien direct du formulaire de la démarche "Signalements impayés de loyer"
    Et que je clique sur "Débuter ma demande"
    Et que je remplis les informations du contact "Administrateur local" avec :
      | Nom    | Prénom | Email               | Téléphone  | Fonction              |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0836656565 | Administrateur local |
    Et que je remplis les informations du contact "Délégué à la protection des données" avec :
      | Nom   | Prénom | Email             | Téléphone  |
      | Durand | Paul  | dpo@exemple.gouv.fr | 0836656566 |
    Et que je remplis les informations du contact "RSSI" avec :
      | Nom   | Prénom | Email                 | Téléphone  |
      | Martin | Inès  | ines.martin@gouv.fr   | 0836656567 |
    Et que j'enregistre et continue vers le résumé
    Et que j'adhère aux conditions générales
    Et que je coche "Je confirme que le délégué à la protection des données de mon organisation est informé de ma demande."
    Et que je clique sur "Soumettre la demande d'habilitation"
    Alors il y a un message de succès contenant "soumise avec succès"

  Scénario: Je soumets une demande avec un champ du RSSI manquant
    Quand j'ouvre le lien direct du formulaire de la démarche "Signalements impayés de loyer"
    Et que je clique sur "Débuter ma demande"
    Et que je remplis les informations du contact "Administrateur local" avec :
      | Nom    | Prénom | Email               | Téléphone  | Fonction              |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0836656565 | Administrateur local |
    Et que je remplis les informations du contact "Délégué à la protection des données" avec :
      | Nom    | Prénom | Email               | Téléphone  |
      | Durand | Paul   | dpo@exemple.gouv.fr | 0836656566 |
    Et que je remplis les informations du contact "RSSI" avec :
      | Nom   | Prénom | Email               | Téléphone  |
      | Martin |       | ines.martin@gouv.fr | 0836656567 |
    Et que j'enregistre et continue vers le résumé
    Alors il y a un message d'erreur contenant "Nous n’avons pas pu sauvegarder votre demande"
    Et il y a au moins une erreur sur un champ

  @javascript
  Scénario: Une adresse de service est acceptée pour le DPO
    Quand j'ouvre le lien direct du formulaire de la démarche "Signalements impayés de loyer"
    Et que je clique sur "Débuter ma demande"
    Et que je remplis les informations du contact "Délégué à la protection des données" avec :
      | Email                      |
      | secretariat@exemple.gouv.fr |
    Alors la page ne contient pas "doit être un email nominatif"

  @javascript
  Scénario: Une adresse générique est refusée pour le RSSI
    Quand j'ouvre le lien direct du formulaire de la démarche "Signalements impayés de loyer"
    Et que je clique sur "Débuter ma demande"
    Et que je remplis les informations du contact "RSSI" avec :
      | Email               |
      | secretariat@gouv.fr |
    Alors la carte de contact "RSSI" contient "doit être un email nominatif"

  Scénario: Je veux démarrer une demande alors que j'ai déjà une demande en cours
    Quand j'ai 1 demande d'habilitation "Signalements impayés de loyer"
    Et que j'ouvre le lien direct du formulaire de la démarche "Signalements impayés de loyer"
    Alors la page contient "Vous ne pouvez pas créer de nouvelle habilitation"
    Et la page contient "possède déjà une demande en cours"
