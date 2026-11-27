# language: fr

Fonctionnalité: Isolation de la base de données de test
  Les données d’un scénario ne sont jamais validées en base : seule la connexion qui les a écrites les voit.

  Scénario: Les données du scénario restent visibles quand un autre fil utilise la base après une requête
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand un autre fil utilise la base de données juste après ma requête
    Alors mon compte est toujours visible dans la base de données
