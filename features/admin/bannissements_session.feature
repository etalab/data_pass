# language: fr

Fonctionnalité: Blocage des utilisateurs bannis en cours de session
  En tant qu'utilisateur banni en cours de session
  Je suis déconnecté et bloqué à ma prochaine requête

  Scénario: Un utilisateur banni en cours de session est déconnecté à sa prochaine requête
    Étant donné que je suis un demandeur
    Et que je me connecte
    Et que l'utilisateur "demandeur@gouv.fr" est banni par un admin
    Quand je me rends sur mon tableau de bord
    Alors il y a un message d'erreur contenant "Votre accès à DataPass a été suspendu"