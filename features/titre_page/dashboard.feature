# language: fr

Fonctionnalité: Titre de page du tableau de bord
  En tant qu'utilisateur connecté
  Je veux voir un titre de page pertinent pour le tableau de bord
  Afin de pouvoir identifier facilement la page dans l’historique et les onglets

  Scénario: Le titre de la page du tableau de bord utilisateur est Tableau de bord
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je me rends sur le chemin "/tableau-de-bord"
    Alors le titre de la page est "Tableau de bord - DataPass"

  Scénario: Le titre de la page du tableau de bord instructeur est Tableau de bord instructeur
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte
    Quand je me rends sur le chemin "/instruction/tableau-de-bord/demandes"
    Alors le titre de la page est "Tableau de bord instructeur - DataPass"
