# language: fr

Fonctionnalité: Connexion avec ProConnect dirigeant
  Le dirigeant d’une entreprise privée se connecte avec ProConnect et la double
  authentification, puis ProConnect vérifie aussitôt qu’il dirige l’entreprise choisie.

  Scénario: Le dirigeant d’une entreprise privée se connecte et fait certifier son statut
    Sachant que je suis dirigeant d’une entreprise privée
    Et que ProConnect certifie que je suis dirigeant de mon organisation
    Quand je me rends sur la page de vérification de dirigeant
    Et que je clique sur "Me connecter avec ProConnect dirigeant"
    Alors la page contient "ProConnect certifie que vous êtes dirigeant de cette entreprise."

  Scénario: Un agent public utilise le bouton dirigeant
    Sachant que je suis un demandeur de la commune de Clamart
    Quand je me rends sur la page de vérification de dirigeant
    Et que je clique sur "Me connecter avec ProConnect dirigeant"
    Alors la page contient "Votre organisation relève du secteur public. La certification dirigeant est réservée aux entreprises privées."
