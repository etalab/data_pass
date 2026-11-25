# language: fr

Fonctionnalité: Vérification du statut de dirigeant par ProConnect
  En tant que demandeur connecté, je peux faire vérifier par ProConnect que je suis
  dirigeant de l’entreprise de mon organisation. Le résultat est affiché, et la date de la
  certification est retenue sur mon rattachement à l’organisation.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Et que je me rends sur la page de vérification de dirigeant

  Scénario: ProConnect certifie mon statut de dirigeant
    Sachant que ProConnect certifie que je suis dirigeant de mon organisation
    Quand je clique sur "Vérifier avec ProConnect"
    Alors la page contient "ProConnect certifie que vous êtes dirigeant de cette entreprise."
    Et la page contient "https://proconnect.gouv.fr/assurance/certification-dirigeant"
    Et la page contient "pwd, mfa"

  Scénario: ProConnect ne certifie pas mon statut de dirigeant
    Sachant que ProConnect ne certifie pas mon statut de dirigeant
    Quand je clique sur "Vérifier avec ProConnect"
    Alors la page contient "ProConnect n’a pas certifié votre statut de dirigeant."

  Scénario: Le compte ProConnect n’est pas celui de la session
    Sachant que ProConnect certifie un autre compte comme dirigeant
    Quand je clique sur "Vérifier avec ProConnect"
    Alors la page contient "Le compte ProConnect utilisé n’est pas celui avec lequel vous êtes connecté à DataPass."

  Scénario: L’entreprise certifiée n’est pas celle de la connexion
    Sachant que ProConnect certifie que je suis dirigeant d’une autre entreprise
    Quand je clique sur "Vérifier avec ProConnect"
    Alors la page contient "L’entreprise choisie pour la certification dirigeant n’est pas celle choisie pour votre connexion."

  Scénario: ProConnect interrompt la vérification
    Sachant que ProConnect interrompt la vérification de dirigeant
    Quand je clique sur "Vérifier avec ProConnect"
    Alors la page contient "ProConnect a interrompu la vérification."
    Et la page contient "Vérifier mon statut de dirigeant"
