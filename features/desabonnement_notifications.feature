# language: fr

Fonctionnalité: Désinscription des notifications en 1 clic depuis l’email
  Un instructeur peut se désinscrire d’une notification en cliquant sur un lien
  signé présent dans le footer des emails d’instruction, sans se reconnecter.

  Scénario: Un instructeur peut voir la page de confirmation via un token valide
    Sachant que je suis un instructeur "API Entreprise"
    Et qu'il existe un token de désinscription valide pour cet instructeur
    Quand je me rends sur la page de désinscription avec ce token
    Alors je suis sur la page "Désinscription des notifications"
    Et la page contient "Confirmer la désinscription"

  Scénario: La confirmation GET n’effectue aucune désactivation
    Sachant que je suis un instructeur "API Entreprise"
    Et qu'il existe un token de désinscription valide pour cet instructeur
    Quand je me rends sur la page de désinscription avec ce token
    Alors la préférence de notification n’a pas changé

  Scénario: Un instructeur peut désactiver ses notifications via le POST
    Sachant que je suis un instructeur "API Entreprise"
    Et qu'il existe un token de désinscription valide pour cet instructeur
    Quand je me rends sur la page de désinscription avec ce token
    Et que je clique sur "Confirmer la désinscription"
    Alors je suis sur la page "Préférence enregistrée"
    Et la page contient "Vous ne recevrez plus d’email concernant"
    Et la notification de soumission est désactivée pour cet instructeur

  Scénario: La désactivation est idempotente
    Sachant que je suis un instructeur "API Entreprise"
    Et qu'il existe un token de désinscription valide pour cet instructeur
    Quand je me rends sur la page de désinscription avec ce token
    Et que je clique sur "Confirmer la désinscription"
    Et que je me rends sur la page de désinscription avec ce token
    Et que je clique sur "Confirmer la désinscription"
    Alors je suis sur la page "Préférence enregistrée"

  Scénario: Un token invalide affiche une page d’erreur
    Quand je me rends sur le chemin "/desabonnement-notifications?token=token_invalide"
    Alors je suis sur la page "Lien invalide ou expiré"
    Et la page contient "Gérer mes préférences sur mon compte"

  Scénario: Un token expiré affiche une page d’erreur
    Sachant que je suis un instructeur "API Entreprise"
    Et qu'il existe un token de désinscription expiré pour cet instructeur
    Quand je me rends sur la page de désinscription avec ce token
    Alors je suis sur la page "Lien invalide ou expiré"

  Scénario: Un token valide mais un rôle révoqué affiche une page d’erreur
    Sachant que je suis un instructeur "API Entreprise"
    Et qu'il existe un token de désinscription valide pour cet instructeur
    Et que cet instructeur a perdu son rôle sur API Entreprise
    Quand je me rends sur la page de désinscription avec ce token
    Alors je suis sur la page "Lien invalide ou expiré"
