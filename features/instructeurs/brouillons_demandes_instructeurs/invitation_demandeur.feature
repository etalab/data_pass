# language: fr

Fonctionnalité: Instruction: invitation d'un demandeur à des demandes d'habilitations d'instructeur
  Un instructeur peut inviter un demandeur à déposer une demande depuis une demande d'habilitation d'instructeur.
  L'instructeur renseigne le siret de l'organisation du demandeur ainsi que son adresse email.
  Le demandeur reçoit un email avec un lien vers la demande d'habilitation pré-remplie.

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte
    Et que j'ai une demande d'habilitation à partager pour "API Entreprise" intitulée "Mon projet test"

  @AvecCourriels
  Scénario: Je peux inviter un demandeur à déposer une demande d'habilitation avec son email et un siret
    Quand je me rends sur la page de gestion des demandes d'habilitation d'instructeur
    Et que je clique sur "Inviter"
    Et que je remplis "Adresse email du demandeur" avec "demandeur@example.com"
    Et que je remplis "Numéro de SIRET de l'organisation" avec "13002526500013"
    Et que je remplis "Note associée à l'invitation" avec "Merci de finaliser la demande comme discuté au téléphone."
    Et que je clique sur "Envoyer"
    Alors il y a un message de succès contenant "avec succès"
    Et un email est envoyé contenant "Merci de finaliser la demande comme discuté au téléphone." à "demandeur@example.com"
    Et la page contient un lien vers "finaliser"
    Et il n'y a pas de bouton "Inviter"

  Scénario: Je ne peux pas inviter un demandeur avec un email invalide
    Quand je me rends sur la page de gestion des demandes d'habilitation d'instructeur
    Et que je clique sur "Inviter"
    Et que je remplis "Adresse email du demandeur" avec "invalid-email"
    Et que je remplis "Numéro de SIRET de l'organisation" avec "13002526500013"
    Et que je remplis "Note associée à l'invitation" avec "Merci de finaliser la demande."
    Et que je clique sur "Envoyer"
    Alors il y a un message d'erreur contenant "email est invalide"

  @SiretInexistant
  Scénario: Je ne peux pas inviter un demandeur avec un siret invalide
    Quand je me rends sur la page de gestion des demandes d'habilitation d'instructeur
    Et que je clique sur "Inviter"
    Et que je remplis "Adresse email du demandeur" avec "demandeur@example.com"
    Et que je remplis "Numéro de SIRET de l'organisation" avec "invalid-siret"
    Et que je remplis "Note associée à l'invitation" avec "Merci de finaliser la demande."
    Et que je clique sur "Envoyer"
    Alors il y a un message d'erreur contenant "SIRET est invalide"
