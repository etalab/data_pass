# language: fr

Fonctionnalité: Instruction: invitation d'un demandeur à des demandes d'habilitations d'instructeur
  Un instructeur peut inviter un demandeur à déposer une demande depuis une demande d'habilitation d'instructeur.
  L'instructeur renseigne le siret de l'organisation du demandeur ainsi que son adresse email.
  Le demandeur reçoit un email avec un lien vers la demande d'habilitation pré-remplie.

  Scénario: Je peux inviter un demandeur à déposer une demande d'habilitation avec son email et un siret
    Étant donné que je suis un instructeur
    Et que j'ai une demande d'habilitation à partager pour "API Entreprise" intitulée "Mon projet test"
    Quand je me rends sur la page de gestion des demandes d'habilitation d'instructeur
    Et que je clique sur le bouton "Inviter un usager à revendiquer la demande"
    Et que je renseigne l'email "demandeur@example.com"
    Et que je renseigne le siret "13002526500013"
    Et que je clique sur le bouton "Envoyer l'invitation"
    Alors je vois le message "L'invitation a été envoyée avec succès au demandeur"
    Et un email d'invitation est envoyé à "demandeur@example.com"

  Scénario: Je ne peux pas inviter un demandeur avec un email invalide
    Étant donné que je suis un instructeur
    Et que j'ai une demande d'habilitation à partager pour "API Entreprise" intitulée "Mon projet test"
    Quand je me rends sur la page de gestion des demandes d'habilitation d'instructeur
    Et que je clique sur le bouton "Inviter un usager à revendiquer la demande"
    Et que je renseigne l'email "email-invalide"
    Et que je renseigne le siret "13002526500013"
    Et que je clique sur le bouton "Envoyer l'invitation"
    Alors je vois le message d'erreur

  Scénario: Je ne peux pas inviter un demandeur avec un siret invalide
    Étant donné que je suis un instructeur
    Et que j'ai une demande d'habilitation à partager pour "API Entreprise" intitulée "Mon projet test"
    Quand je me rends sur la page de gestion des demandes d'habilitation d'instructeur
    Et que je clique sur le bouton "Inviter un usager à revendiquer la demande"
    Et que je renseigne l'email "demandeur@example.com"
    Et que je renseigne le siret "siret-invalide"
    Et que je clique sur le bouton "Envoyer l'invitation"
    Alors je vois le message d'erreur
