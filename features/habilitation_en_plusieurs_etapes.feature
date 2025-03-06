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

  Scénario: Quand j'arrive sur une nouvelle demande en plusieurs étapes
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Demande libre"
    Et que je clique sur "Débuter ma demande"
    Alors la page contient "Nom du projet"
    Et la page contient "Prochaine étape"
    Et la page ne contient pas "Supprimer"
    Et la page contient "Enregistrer"
    Et la page contient "Suivant"

  Scénario: J'enregistre une demande d'habilitation en plusieurs étapes sur la première étape
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Demande libre"
    Et que je clique sur "Débuter ma demande"
    Et que je remplis "Nom du projet" avec "Je suis un projet"
    Et que je remplis "Description du projet" avec "Je suis une description"
    Et que je clique sur "Enregistrer"
    Alors il y a un message de succès contenant "été sauvegardé"
    Et la page contient "Nom du projet"
    Et la page contient "Prochaine étape : Le traitement des données personnelles"

  Scénario: J'enregistre en avançant une demande d'habilitation en plusieurs étapes depuis la première étape
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Demande libre"
    Et que je clique sur "Débuter ma demande"
    Et que je remplis "Nom du projet" avec "Je suis un projet"
    Et que je remplis "Description du projet" avec "Je suis une description"
    Et que je clique sur "Suivant"
    Alors il n'y a pas de message d'alerte contenant "été sauvegardé"
    Et la page contient "Destinataire des données"
    Et la page contient "Prochaine étape : Le cadre juridique"

  Scénario: Je tente d'enregistrer une demande d'habilitation en plusieurs étapes depuis la première étape en cliquant sur suivant
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Demande libre"
    Et que je clique sur "Débuter ma demande"
    Et que je clique sur "Suivant"
    Alors il y a un message d'erreur contenant "Nom du projet doit être"
    Et la page contient "Nom du projet"

