# language: fr

Fonctionnalité: Messagerie lié à des demandes
  Un demandeur peut communiquer avec l'équipe d'instruction à travers la page
  de la demande d'habilitation.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je peux consulter l'historique de conversation sur une de mes demandes non-validées
    Quand j'ai 1 demande d'habilitation "API Entreprise" en brouillon
    Et que cette habilitation a un message de l'instructeur avec comme corps "Message 1"
    Et que cette habilitation a un message du demandeur avec comme corps "Message 2"
    Et que je me rends sur cette demande d'habilitation
    Et que je clique sur la bulle de messagerie
    Alors la page contient "Message 1"
    Et la page contient "Message 2"

  Scénario: Je vois une pastille sur le tableau de bord lorsqu'un nouveau message est présent
    Quand j'ai 1 demande d'habilitation "API Entreprise" en brouillon
    Et que cette habilitation a un message de l'instructeur avec comme corps "Message 1"
    Et que je vais sur la page du tableau de bord
    Alors je vois un badge de nouveau message contenant "1"

  Scénario: Je vois une pastille sur la demande d'habilitation lorsqu'un nouveau message est présent
    Quand j'ai 1 demande d'habilitation "API Entreprise" en brouillon
    Et que cette habilitation a un message de l'instructeur avec comme corps "Message 1"
    Et que cette habilitation a un message de l'instructeur avec comme corps "Message 2"
    Et que je me rends sur cette demande d'habilitation
    Alors je vois un badge de nouveau message contenant "2"

  Scénario: La pastille de nouveau message se retire lorsque l'on consulte les messages
    Quand j'ai 1 demande d'habilitation "API Entreprise" en brouillon
    Et que cette habilitation a un message de l'instructeur avec comme corps "Message"
    Et que je me rends sur cette demande d'habilitation
    Et que je clique sur la bulle de messagerie
    Et que je vais sur la page du tableau de bord
    Alors il n'y a pas de badge de nouveau message

  @AvecCourriels
  Scénario: J'envoie un message aux instructeurs
    Quand j'ai 1 demande d'habilitation "API Entreprise" en brouillon
    Et que il existe un instructeur pour cette demande d'habilitation
    Et que je me rends sur cette demande d'habilitation
    Et que je clique sur la bulle de messagerie
    Et que je remplis "Corps du message" avec "Bonjour, je suis le demandeur"
    Et que je clique sur "Envoyer"
    Alors la page contient "Bonjour, je suis le demandeur"
    Et un email est envoyé contenant "nouveau message"
