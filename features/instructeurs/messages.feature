# language: fr

Fonctionnalité: Instruction: messagerie
  Un instructeur peut communiquer avec un demandeur à travers la page
  de la demande d'habilitation.

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je suis un instructeur "API Impôt Particulier"
    Et que je me connecte

  Scénario: Je vois l'historique des messages
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modérer
    Et que cette habilitation a un message du demandeur avec comme corps "Je ne comprends pas"
    Et que je clique sur "Messagerie"
    Alors la page contient "Je ne comprends pas"
    Et la page contient "Dupont Jean"

  Scénario: Je vois une pastille lorsqu'un nouveau message est présent
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modérer
    Et que cette habilitation a un message du demandeur avec comme corps "Je ne comprends pas"
    Et que je clique sur "Demande"
    Alors la page contient "Messagerie 1"

  Scénario: La pastille de nouveau message se retire lorsque l'on consulte les messages
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modérer
    Et que cette habilitation a un message du demandeur avec comme corps "Je ne comprends pas"
    Et que je clique sur "Messagerie"
    Alors la page contient "Messagerie"
    Et la page ne contient pas "Messagerie 1"

  @AvecCourriels
  Scénario: J'envoie un message au demandeur
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modérer
    Et que je clique sur "Messagerie"
    Et que je remplis "Corps du message" avec "Bonjour, je suis l'instructeur"
    Et que je clique sur "Envoyer"
    Alors la page contient "Bonjour, je suis l'instructeur"
    Et un email est envoyé contenant "nouveau message"

  Scénario: Il y a un formulaire d'envoi de messages sur une habilitation validée
    Quand je me rends sur une demande d'habilitation "API Entreprise" validée
    Et que je clique sur "Messagerie"
    Alors il y a un bouton "Envoyer"

  Scénario: Je ne peux pas consulter ni envoyer de messages sur un type de demande sans messagerie activée
    Quand je me rends sur une demande d'habilitation "API Impôt Particulier" à modérer
    Alors la page ne contient pas "Messagerie"
