# language: fr

Fonctionnalité: Module "Temps moyen de traitement"
  Scénario: Voir le temps moyen de traitement
    Etant donné que le temps moyen de traitement est de 66 jours
    Quand je veux remplir une demande pour "API Entreprise"
    Alors la page contient "66 jours"
