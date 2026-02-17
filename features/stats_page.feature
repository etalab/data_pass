# language: fr

Fonctionnalité: Page de statistiques
  En tant que visiteur
  Je veux voir les statistiques de DataPass
  Afin de consulter les métriques publiques

  Scénario: Je visite la page de stats
    Quand je vais sur la page des stats
    Alors la page contient "Statistiques DataPass"

  Scénario: Accès public à la page de statistiques
    Quand je vais sur la page des stats
    Alors la page contient "Statistiques DataPass"
    Et la page contient "Demandes soumises"
    Et la page contient "Demandes validées"
    Et la page contient "Durée de remplissage d’une nouvelle demande"

  Scénario: Filtrage par période
    Quand je vais sur la page des stats
    Alors je vois un champ de date pour la période de début
    Et je vois un champ de date pour la période de fin

  @javascript
  Scénario: Avertissement pour les données antérieures à 2025
    Quand je visite la page des stats avec les paramètres "start_date=2024-01-01&end_date=2024-12-31"
    Alors la page contient "Données antérieures à 2025"
    Et la page contient "migrée depuis une ancienne version"

  @javascript
  Scénario: Pas d’avertissement pour les données de 2025 et après
    Quand je visite la page des stats avec les paramètres "start_date=2025-01-01&end_date=2025-12-31"
    Alors la page ne contient pas "Données antérieures à 2025"
