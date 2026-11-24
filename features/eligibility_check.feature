# language: fr

@javascript
Fonctionnalité: Vérification de l'éligibilité avant l'habilitation
  En tant qu'utilisateur non connecté, je dois vérifier mon éligibilité
  avant de pouvoir accéder au formulaire de demande d'habilitation

  Scénario: Un utilisateur non connecté voit l'arbre de décision d'éligibilité
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Alors le titre de la page est "Vérifier votre éligibilité - API Particulier - DataPass"
    Et le titre principal de la page contient "Vérifier votre éligibilité"
    Et le titre principal de la page contient "API Particulier"
    Et la page ne contient pas "Bienvenue sur DataPass"
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

  Scénario: Un établissement d’accueil du jeune enfant ne voit que les formulaires EAJE après connexion
    Sachant que je suis un demandeur
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Et je choisis "Un établissement d’accueil du jeune enfant (EAJE)"
    Et je clique sur "Demander l'accès aux données"
    Et je clique sur "S’identifier avec ProConnect"
    Et que je choisis "Vos développeurs"
    Alors je vois 2 tuiles
    Et je vois 1 tuile "Tarification d’accueil du jeune enfant par un EAJE bénéficiant de la PSU"

  Scénario: Un utilisateur connecté ne voit pas l'arbre de décision
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Alors la page ne contient pas "Êtes-vous :"

  Scénario: Un utilisateur pour une API sans règles d'éligibilité voit directement ProConnect
    Quand je démarre une nouvelle demande d'habilitation "API Mobilic"
    Alors la page ne contient pas "Êtes-vous :"
    Et la page contient "S’identifier avec ProConnect"

  Scénario: API Entreprise affiche ses propres libellés d’éligibilité
    Quand je démarre une nouvelle demande d'habilitation "API Entreprise"
    Alors la page contient "Un particulier"
    Et la page contient "Une entité publique ou un organisme privé investi d’une mission de service public"
    Et la page contient "Une entreprise ou une association souhaitant intégrer API Entreprise en tant qu’éditeur"
    Et la page ne contient pas "Une collectivité ou une administration"

  Scénario: Une entité publique d’API Entreprise est éligible et continue le parcours habituel
    Quand je démarre une nouvelle demande d'habilitation "API Entreprise"
    Et je choisis "Une entité publique ou un organisme privé investi d’une mission de service public"
    Alors la page contient "vous êtes éligible à l'utilisation de l'API Entreprise"
    Et il y a un bouton "Demander l'accès aux données"

  Scénario: Un éditeur est orienté vers le questionnaire de qualification
    Quand je démarre une nouvelle demande d'habilitation "API Entreprise"
    Alors le titre principal de la page contient "API Entreprise"
    Quand je choisis "Une entreprise ou une association souhaitant intégrer API Entreprise en tant qu’éditeur"
    Alors l’encadré est "fr-callout--pink-macaron" avec l’icône "fr-icon-close-circle-line"
    Et la page contient "Vous n’avez pas besoin de faire une demande sur DataPass"
    Et la page contient un lien vers "form.typeform.com"
    Et la page contient "nouvelle fenêtre"
    Et il y a un bouton "Répondre au questionnaire éditeur"
    Et la page ne contient pas "Demander l'accès aux données"
    Et la page ne contient pas "Déposer une demande Editeur"

  Scénario: Sur ordinateur, l’encadré s’affiche à droite des réponses
    Sachant que la fenêtre fait 1366 pixels de large
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Alors l’illustration est affichée
    Et la page contient "Choisissez votre situation : le résultat s’affichera ici."
    Quand je choisis "Une collectivité ou une administration"
    Alors l’encadré s’affiche à droite des réponses
    Et l’encadré est "fr-callout--green-emeraude" avec l’icône "fr-icon-checkbox-circle-line"
    Et l’illustration n’est pas affichée
    Et la page ne contient pas "Choisissez votre situation"
    Quand je choisis "Un particulier"
    Alors l’encadré s’affiche à droite des réponses
    Et la page contient "Vous n’êtes pas autorisé"
    Et la page ne contient pas "vous êtes éligible"

  Scénario: Sur téléphone, l’encadré s’affiche sous la réponse cochée
    Sachant que la fenêtre fait 390 pixels de large
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Alors l’illustration n’est pas affichée
    Et la page ne contient pas "Choisissez votre situation"
    Quand je choisis "Une collectivité ou une administration"
    Alors l’encadré de "Une collectivité ou une administration" s’affiche sous cette réponse
    Quand je choisis "Un particulier"
    Alors l’encadré de "Un particulier" s’affiche sous cette réponse
    Et la page ne contient pas "vous êtes éligible"

  Scénario: L’encadré change de place quand la largeur de l’écran change
    Sachant que la fenêtre fait 390 pixels de large
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Et je choisis "Une collectivité ou une administration"
    Et la fenêtre fait 1366 pixels de large
    Alors l’encadré s’affiche à droite des réponses
    Et la réponse "Une collectivité ou une administration" est cochée
    Quand la fenêtre fait 390 pixels de large
    Alors l’encadré de "Une collectivité ou une administration" s’affiche sous cette réponse

  Scénario: Une collectivité d’API FICOBA voit un encadré jaune avec un point d’interrogation
    Quand je démarre une nouvelle demande d'habilitation "API Fichier des Comptes Bancaires et Assimilés (FICOBA)"
    Et je choisis "Une collectivité ou une administration"
    Alors l’encadré est "fr-callout--yellow-tournesol" avec l’icône "fr-icon-question-line"
    Et il y a un bouton "Demander l'accès aux données"
