# language: fr

@javascript
Fonctionnalité: Vérification de l'éligibilité avant l'habilitation
  En tant qu'utilisateur non connecté, je dois vérifier mon éligibilité
  avant de pouvoir accéder au formulaire de demande d'habilitation

  Scénario: Un utilisateur non connecté voit l'arbre de décision d'éligibilité
    Quand je me rends sur la page de démarrage d'une demande "API Particulier"
    Alors la page contient "Qui êtes-vous ?"
    Et la page contient "Particulier"
    Et la page contient "Collectivité ou administration"
    Et la page contient "Entreprise ou association"

  Scénario: Un particulier voit qu'il n'est pas éligible
    Quand je me rends sur la page de démarrage d'une demande "API Particulier"
    Et je sélectionne "Particulier"
    Alors la page contient "Vous n’êtes pas autorisé"
    Et la page ne contient pas "Demander l'accès aux données"

  Scénario: Une collectivité voit qu'elle est éligible et peut continuer
    Quand je me rends sur la page de démarrage d'une demande "API Particulier"
    Et je sélectionne "Collectivité ou administration"
    Alors la page contient "vous êtes éligible"
    Et je vois un lien "Demander l'accès aux données"
    Quand je clique sur "Demander l'accès aux données"
    Et la page contient "S’identifier avec ProConnect"

  Scénario: Un utilisateur connecté ne voit pas l'arbre de décision
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je me rends sur la page de démarrage d'une demande "API Particulier"
    Alors la page ne contient pas "Qui êtes-vous ?"

  Scénario: Un utilisateur pour une API sans règles d'éligibilité voit directement ProConnect
    Quand je me rends sur la page de démarrage d'une demande "API Mobilic"
    Alors la page ne contient pas "Qui êtes-vous ?"
    Et la page contient "S’identifier avec ProConnect"
