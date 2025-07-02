# language: fr

@javascript @DisableBullet
Fonctionnalité: Instruction: affichage des messages dans l'historique
  En tant qu'instructeur
  Je veux pouvoir voir et masquer les messages détaillés dans l'historique des habilitations

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte
    Et qu'il y a 1 demande d'habilitation "API Entreprise" en attente
    Et que cette demande a été "sujet à modification" avec le message "Merci de corriger les informations suivantes : la description du projet est trop vague."
    Et que je me rends sur mon tableau de bord instructeur
    Et que je clique sur "Consulter"
    Et que je clique sur "Historique"

  Scénario: Je vois un aperçu du message avec un bouton "voir le message"
    Alors la page contient "a demandé des modifications"
    Et la page contient "voir le message"
    Et la page ne contient pas "Merci de corriger les informations suivantes"

  Scénario: Je clique sur "voir le message" et je vois le message complet
    Quand je clique sur "voir le message"
    Alors la page contient "Merci de corriger les informations suivantes : la description du projet est trop vague"
    Et la page contient "masquer le message"
    Et la page ne contient pas "voir le message"

  Scénario: Je clique sur "masquer le message" et l'aperçu est à nouveau affiché
    Quand je clique sur "voir le message"
    Et je clique sur "masquer le message"
    Alors la page contient "a demandé des modifications"
    Et la page contient "voir le message"
    Et la page ne contient pas "Merci de corriger les informations suivantes"
