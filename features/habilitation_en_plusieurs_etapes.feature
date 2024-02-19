# language: fr

Fonctionnalité: Interactions sur une demande d'habilitation en plusieurs étapes
  Une demande d'habilitation en plusieurs étapes propose de remplir pour la première fois
  l'ensemble des informations via un formulaire guidé à étapes. Dès que celle-ci est soumise
  une première fois ou dès que l'on arrive à la dernière étape du résumé, le formulaire à étape
  n'est plus utilisé.

  Dans le cas d'une demande de modification ou en brouillon en étape finale, modifier un bloc
  ouvre la page de l'étape sans pour autant permettre de se déplacer dans les étapes.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: J'enregistre une demande d'habilitation en plusieurs étapes sur la première étape
    Quand je démarre une nouvelle demande d'habilitation "API Particulier"
    Et que je remplis "Nom du projet" avec "Je suis un projet"
    Et que je clique sur "Enregistrer"
    Et il y a un message de succès contenant "été mise à jour"
