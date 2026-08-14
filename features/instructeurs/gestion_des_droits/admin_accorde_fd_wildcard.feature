# language: fr

Fonctionnalité: Instruction — un administrateur peut accorder un droit FD-wildcard (fix Valentin)
  En tant qu’administrateur, je peux accorder « Tous les services » d’un fournisseur
  de données depuis l’interface d’instruction, sans devoir m’attribuer au préalable
  un rôle manager sur tout ce fournisseur (admin ⇒ *:*:*).

  Contexte:
    Sachant que je suis un manager "API Entreprise"
    Et que je me connecte
    Et que je suis aussi administrateur

  Scénario: J’accorde un droit sur tous les services DINUM depuis l’instruction
    Quand il y a l'utilisateur "cible@gouv.fr" sans rôle
    Et que je me rends sur la page d'ajout de droits d'instruction
    Et que je remplis "Email de l’utilisateur" avec "cible@gouv.fr"
    Et que je sélectionne "Tous les services DINUM" pour "Portée des droits"
    Et que je sélectionne "Instructeur" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors il y a un message de succès contenant "mis à jour"
    Et l'utilisateur "cible@gouv.fr" a les rôles "dinum:*:instructor"
