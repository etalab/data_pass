# language: fr

Fonctionnalité: Instruction: historique habilitation
  Une habilitation possède un historique en fonction des actions des demandeurs et instructeurs

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte

  Scénario: Je vois les événements
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modérer
    Et je clique sur "Valider"
    Et je clique sur "Valider la demande d'habilitation"
    Et que je clique sur "Consulter"
    Et que je clique sur "Historique"
    Alors la page contient "a approuvé la demande"
    Et la page contient "a soumis la demande"

  @DisableBullet
  Scénario: Je vois les modifications apportées entre 2 soumissions
    Quand il y a 1 demande d'habilitation "API Entreprise" en attente
    Et que cette demande a été "sujet à modification"
    Et que cette demande a été modifiée avec les informations suivantes :
      | champ       | nouvelle valeur                |
      | intitule    | Nouvelle valeur de titre       |
      | description | Nouvelle valeur de description |
    Et que cette demande a été "soumise"
    Et que je vais sur la page instruction
    Et que je clique sur "Consulter"
    Et que je clique sur "Historique"
    Alors la page contient "Le champ \"Nom du projet\" a changé de \"Demande d'accès à la plateforme fournisseur\" en \"Nouvelle valeur de titre\""
    Et la page contient "Le champ \"Description du projet\" a changé de \"Description de la demande\" en \"Nouvelle valeur de description\""
