# language: fr

Fonctionnalité: Page de statistiques
  En tant que visiteur
  Je veux voir les statistiques de DataPass
  Afin de consulter les métriques publiques

  Scénario: Accès public à la page de statistiques
    Quand je visite "/stats"
    Alors je vois "Statistiques DataPass"
    Et je vois "Nouvelles demandes"
    Et je vois "Validations"
    Et je vois "Durées médianes pour les nouvelles demandes"

  Scénario: Filtrage par période
    Quand je visite "/stats"
    Alors je vois un champ de date pour la période de début
    Et je vois un champ de date pour la période de fin

  Scénario: Affichage des statistiques par dimension
    Quand je visite "/stats"
    Alors je vois "Statistiques par"
    Et je vois un sélecteur de dimension
