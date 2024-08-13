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

  Scénario: Je veux démarrer une demande d'habilitation alors que j'ai déjà une habilitation validée avec token
    Quand j'ai déjà une demande d'habilitation "Portail HubEE - Démarche CertDC" validée avec token
    Et que je vais sur la page des demandes
    Et que je clique sur "Remplir une demande" pour l'habilitation "Portail HubEE - Démarche CertDC"
    Alors la page contient "Vous ne pouvez pas créer de nouvelle habilitation"
    Et la page contient "possède déjà une habilitation"
    Et je peux voir le bouton "Débuter ma demande" grisé et désactivé
    Quand je clique sur "Consulter l'habilitation existante"
    Alors la page contient "Validée"

  Scénario: Je veux démarrer une demande d'habilitation alors que j'ai déjà une demande en cours
    Quand j'ai déjà une demande d'habilitation "Portail HubEE - Démarche CertDC" en cours
    Et que je vais sur la page des demandes
    Et que je clique sur "Remplir une demande" pour l'habilitation "Portail HubEE - Démarche CertDC"
    Alors la page contient "Vous ne pouvez pas créer de nouvelle habilitation"
    Et la page contient "possède déjà une demande en cours"
    Et je peux voir le bouton "Débuter ma demande" grisé et désactivé
    Quand je clique sur "Consulter la demande en cours"
    Alors la page contient "Brouillon"

  Scénario: Je vois un lien vers le portail HubEE quand je consulte une habilitation validée avec token
    Quand j'ai déjà une demande d'habilitation "Portail HubEE - Démarche CertDC" validée avec token
    Et que je vais sur la page du tableau de bord
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "Portail HubEE - Démarche CertDC"
    Et la page contient un lien vers "portail.hubee.numerique.gouv.fr"

  Scénario: Je ne vois aucun lien vers le portail HubEE quand je consulte une habilitation qui n'a jamais été validée
    Quand j'ai déjà une demande d'habilitation "Portail HubEE - Démarche CertDC" en cours
    Et que je vais sur la page du tableau de bord
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "Portail HubEE - Démarche CertDC"
    Et la page ne contient aucun lien vers "portail.hubee.numerique.gouv.fr"
