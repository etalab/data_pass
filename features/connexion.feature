# language: fr

Fonctionnalité: Connexion à DataPass
  En tant qu’agent, je me connecte à DataPass depuis une page dédiée,
  vers laquelle je suis renvoyé quand je dois me connecter.

  Scénario: Je me connecte au service via ProConnect
    Sachant que je suis un demandeur
    Et que je me connecte
    Alors je suis sur la page "Demandes et habilitations"
    Et la page contient "DUPONT Jean"
    Et il y a un message de succès contenant "Vous êtes connecté"

  Scénario: La page de connexion porte le bouton ProConnect
    Quand je me rends sur la page de connexion
    Alors le titre de la page est "Connexion - DataPass"
    Et la page contient "S’identifier avec ProConnect"

  Scénario: Un demandeur se connecte depuis la page de connexion
    Sachant que je suis un demandeur
    Quand je me rends sur la page de connexion
    Et que je clique sur "S’identifier avec ProConnect"
    Alors je suis sur mon tableau de bord

  Scénario: Un visiteur déconnecté qui ouvre une page protégée passe par la page de connexion
    Sachant que je suis un demandeur
    Quand je me rends sur le chemin "/demandes"
    Alors je suis sur la page de connexion
    Quand je clique sur "S’identifier avec ProConnect"
    Alors le titre de la page est "Demander une habilitation - DataPass"

  Scénario: Une connexion refusée sans double authentification s’affiche sur la page de connexion
    Sachant que je suis un demandeur
    Quand je me connecte via ProConnect avec l'identité "Renater" sans double authentification
    Alors je suis sur la page de connexion
    Et il y a un message d'erreur contenant "sans avoir une double authentification installée"

  Scénario: Un utilisateur banni est renvoyé sur la page de connexion
    Sachant que je suis un demandeur
    Et que je me connecte
    Et que l'utilisateur "demandeur@gouv.fr" est banni par un admin
    Quand je me rends sur mon tableau de bord
    Alors je suis sur la page de connexion
    Et il y a un message d'erreur contenant "Votre accès à DataPass a été suspendu"

  Scénario: Un utilisateur connecté qui ouvre la page de connexion arrive sur son tableau de bord
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je me rends sur la page de connexion
    Alors je suis sur mon tableau de bord

  Scénario: La racine d’un sous-domaine fournisseur mène à la page de connexion
    Sachant que je consulte le site ayant le sous-domaine "api-entreprise"
    Quand je me rends sur la page d'accueil
    Alors je suis sur la page de connexion
    Et la page contient "S’identifier avec ProConnect"
