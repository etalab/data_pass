# language: fr

Fonctionnalité: Liste vide des fournisseurs de données pour les instructeurs
  En tant qu'instructeur sans fournisseur de données accessible, je vois un
  message m'indiquant qu'aucun fournisseur n'est disponible.

  Scénario: Je vois un message si aucun fournisseur de données n'est accessible
    Sachant que je suis un rapporteur "API Entreprise"
    Et que je me connecte
    Quand je me rends sur la liste des formulaires
    Alors la page contient "Aucun fournisseur de données disponible."
