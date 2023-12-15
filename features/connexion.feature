# language: fr

Fonctionnalité: Connexion à DataPass
  Scénario: Je me connecte au service
    Sachant que je suis un demandeur
    Et que je me connecte
    Alors je suis sur la page "Accueil"
    Et la page contient "demandeur@gouv.fr"
    Et il y a un message de succès contenant "Vous êtes connecté"
