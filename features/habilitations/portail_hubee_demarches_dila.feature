# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation Portail HubEE - Démarches DILA
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je soumets une demande d'habilitation valide
    Quand je démarre une nouvelle demande d'habilitation "Portail HubEE - Démarches DILA"
    * je coche "AEC - Acte d’Etat Civil"
    * je coche "DDPACS - Démarche en ligne de préparation à la conclusion d’un Pacs"
    * je coche "RCO - Recensement Citoyen Obligatoire"
    * je coche "DHTOUR - Déclaration d’hébergement touristique"
    * je coche "JCC - Déclaration de Changement de Coordonnées"
    * je clique sur "Suivant"

    * je remplis les informations du contact "Administrateur métier" avec :
      | Nom    | Prénom | Email               | Téléphone   | Fonction              |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0836656565  | Administrateur métier |
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je remplis une demande d'habilitation avec aucune démarche DILA cochée
    Quand je démarre une nouvelle demande d'habilitation "Portail HubEE - Démarches DILA"
    Et que je clique sur "Suivant"

    Alors il y a un message d'erreur contenant "Une erreur est survenue lors de la sauvegarde de la demande d'habilitation"
    Et il y a un message d'erreur contenant "Les données ne sont pas cochées"
    Et je suis sur la page "Portail HubEE - Démarches DILA"

  Scénario: Je remplis une demande d'habilitation avec un champ du contact manquant
    Quand je démarre une nouvelle demande d'habilitation "Portail HubEE - Démarches DILA"
    * je coche "AEC - Acte d’Etat Civil"
    * je coche "DDPACS - Démarche en ligne de préparation à la conclusion d’un Pacs"
    * je coche "RCO - Recensement Citoyen Obligatoire"
    * je coche "DHTOUR - Déclaration d’hébergement touristique"
    * je coche "JCC - Déclaration de Changement de Coordonnées"
    * je clique sur "Suivant"

    * je remplis les informations du contact "Administrateur métier" avec :
      | Nom    | Prénom | Email               | Téléphone   | Fonction de l'administrateur système |
      | Dupont |        | dupont.jean@gouv.fr | 0836656565  | Administrateur métier |
    Et que je clique sur "Suivant"

    Alors il y a un message d'erreur contenant "Une erreur est survenue lors de la sauvegarde de la demande d'habilitation"
    Et il y a au moins une erreur sur un champ
    Et je suis sur la page "Portail HubEE - Démarches DILA"

  Scénario: Je ne peux pas cocher un scope si celui-ci existe déjà dans une demande envoyée
    Quand je démarre une nouvelle demande d'habilitation "Portail HubEE - Démarches DILA"
    * je coche "AEC - Acte d’Etat Civil"
    * je clique sur "Suivant"

    * je remplis les informations du contact "Administrateur métier" avec :
      | Nom    | Prénom | Email               | Téléphone   | Fonction              |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0836656565  | Administrateur métier |
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Et que je démarre une nouvelle demande d'habilitation "Portail HubEE - Démarches DILA"
    Alors je ne peux pas cocher "AEC - Acte d’Etat Civil"
