# language: fr

@javascript
Fonctionnalité: Vérification de l'éligibilité avant l'habilitation
  En tant qu'utilisateur non connecté, je dois vérifier mon éligibilité
  avant de pouvoir accéder au formulaire de demande d'habilitation

  Scénario: Un utilisateur non connecté voit l'arbre de décision d'éligibilité
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Alors la page contient "Bienvenue sur DataPass !"
    Et la page contient "Êtes-vous :"
    Et la page contient "Un particulier"
    Et la page contient "Une collectivité ou une administration"
    Et la page contient "Une entreprise ou une association"
    Et la page contient "Un établissement d’accueil du jeune enfant (EAJE)"

  Scénario: Un particulier voit qu'il n'est pas éligible
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Et je choisis "Un particulier"
    Alors la page contient "Vous n’êtes pas autorisé"
    Et la page ne contient pas "Demander l'accès aux données"

  Scénario: Une collectivité voit qu'elle est éligible et peut continuer
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Et je choisis "Une collectivité ou une administration"
    Alors la page contient "vous êtes éligible"
    Et il y a un bouton "Demander l'accès aux données"
    Quand je clique sur "Demander l'accès aux données"
    Et la page contient "S’identifier avec ProConnect"

  Scénario: Un établissement d’accueil du jeune enfant voit qu’il est éligible et peut continuer
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Et je choisis "Un établissement d’accueil du jeune enfant (EAJE)"
    Alors la page contient "vous êtes éligible à l’utilisation de l’API Participation familiale dans les EAJE"
    Et il y a un bouton "Demander l'accès aux données"
    Quand je clique sur "Demander l'accès aux données"
    Et la page contient "S’identifier avec ProConnect"

  Scénario: Une entreprise ou une association reste non éligible et peut demander à être référencée
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Et je choisis "Une entreprise ou une association"
    Alors la page contient "Vous n’êtes pas autorisé"
    Et la page ne contient pas "Demander l'accès aux données"
    Et il y a un bouton "Demander à être référencé"

  Scénario: Un établissement d’accueil du jeune enfant connecté retrouve son formulaire
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Et que je choisis "Vos développeurs"
    Alors je vois 1 tuile "Tarification d’accueil du jeune enfant par un EAJE bénéficiant de la PSU"

  Scénario: Un utilisateur connecté ne voit pas l'arbre de décision
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Alors la page ne contient pas "Êtes-vous :"

  Scénario: Un utilisateur pour une API sans règles d'éligibilité voit directement ProConnect
    Quand je démarre une nouvelle demande d'habilitation "API Mobilic"
    Alors la page ne contient pas "Êtes-vous :"
    Et la page contient "S’identifier avec ProConnect"
