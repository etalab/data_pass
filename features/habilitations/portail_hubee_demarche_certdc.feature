# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation Portail HubEE - Démarche CertDC
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je soumets une demande d'habilitation valide
    Quand je démarre une nouvelle demande d'habilitation "Portail HubEE - Démarche CertDC"
    Et que je remplis les informations du contact "Administrateur métier" avec :
      | Nom    | Prénom | Email               | Téléphone   | Fonction              |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0836656565  | Administrateur métier |
    Et que je clique sur "Enregistrer les modifications"
    Et que je clique sur "Continuer vers le résumé"
    Et que j'adhère aux conditions générales
    Et que je clique sur "Soumettre la demande d'habilitation"

   Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation avec un champ du contact manquant
    Quand je démarre une nouvelle demande d'habilitation "Portail HubEE - Démarche CertDC"
    Et que je remplis les informations du contact "Administrateur métier" avec :
      | Nom    | Prénom | Email               | Téléphone   | Fonction de l'administrateur système |
      | Dupont |        | dupont.jean@gouv.fr | 0836656565  | Administrateur métier |
    Et que je clique sur "Enregistrer les modifications"
    Et que je clique sur "Continuer vers le résumé"

    Alors il y a un message d'erreur contenant "Une erreur est survenue lors de la sauvegarde"
    Et il y a au moins une erreur sur un champ
    Et je suis sur la page "Portail HubEE - Démarche CertDC"

  Scénario: Je veux démarrer une demande d'habilitation alors que j'ai déjà une habilitation
    Quand j'ai déjà une demande d'habilitation "Portail HubEE - Démarche CertDC" en cours
    Et que je vais sur la page des demandes
    Alors il n'y a pas le bouton "Remplir une demande" pour l'habilitation "Portail HubEE - Démarche CertDC"

  @Pending
  Scénario: Je veux sousmettre une demande d'habilitation Hubee Cert DC alors qu'une habilitation pour la même organization est déjà en cours
    Quand je démarre une nouvelle demande d'habilitation "Portail HubEE - Démarche CertDC"
    Et que je remplis les informations du contact "Administrateur métier" avec :
      | Nom    | Prénom | Email               | Téléphone  | Fonction de l'administrateur système |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0836656565 | Administrateur métier                |
    Et que je clique sur "Enregistrer les modifications"
    Alors je veux remplir une demande pour "Portail HubEE - Démarche CertDC"
    Et je peux voir le bouton "Débuter ma demande pour Portail HubEE - Démarche CertDC" grisé et désactivé
