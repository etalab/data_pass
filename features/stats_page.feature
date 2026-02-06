# language: fr

Fonctionnalité: Page de statistiques
  En tant que visiteur
  Je veux voir les statistiques de DataPass
  Afin de consulter les métriques publiques

  Scénario: Accès public à la page de statistiques
    Quand je visite "/stats"
    Alors je vois "Statistiques DataPass"
    Et je vois "Nouvelles demandes"
    Et je vois "Instructions validées"
    Et je vois "Remplissage d'une nouvelle demande"

  Scénario: Filtrage par période
    Quand je visite "/stats"
    Alors je vois un champ de date pour la période de début
    Et je vois un champ de date pour la période de fin

  @javascript
  Scénario: Avertissement pour les données antérieures à 2025
    Quand je visite "/stats?start_date=2024-01-01&end_date=2024-12-31"
    Alors je vois "Données antérieures à 2025"
    Et je vois "migrée depuis une ancienne version"

  @javascript
  Scénario: Pas d'avertissement pour les données de 2025 et après
    Quand je visite "/stats?start_date=2025-01-01&end_date=2025-12-31"
    Alors je ne vois pas "Données antérieures à 2025"
