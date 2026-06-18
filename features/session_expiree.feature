# language: fr

Fonctionnalité: Message flash lors de l'expiration de session
  En tant qu'utilisateur dont la session a expiré
  Je suis informé que ma session a expiré lorsque je suis redirigé vers la connexion

  Scénario: Un utilisateur dont la session a expiré est redirigé avec un message d'info
    Étant donné que je suis un demandeur
    Et que ma session a expiré
    Quand je me rends sur mon tableau de bord
    Alors il y a un message d'info contenant "Votre session a expiré"

  Scénario: Un visiteur anonyme est redirigé sans message d'alerte
    Quand je me rends sur mon tableau de bord
    Alors il n'y a pas de message d'alerte contenant "Votre session a expiré"
