# language: fr

Fonctionnalité: Accueil public
  En tant que visiteur, je comprends à quoi sert DataPass
  et je trouve la démarche qui me concerne.

  Scénario: Un visiteur déconnecté voit l’en-tête public, le bandeau et les trois tuiles
    Quand je me rends sur la page d'accueil
    Alors la page contient "Habilitations et registre du portefeuille européen"
    Et la page contient "Portefeuille européen"
    Et la page contient "Le registre des parties utilisatrices du portefeuille européen ouvre le 24 décembre 2026."
    Et je vois 3 tuiles
    Et il y a un badge "Nouveau"

  Scénario: Chaque tuile mène à sa section ou à la page Portefeuille européen
    Quand je me rends sur la page d'accueil
    Alors il y a un lien vers "#acceder"
    Et il y a un lien vers "#administrations"
    Et il y a un lien vers "/#portefeuille-europeen"

  Scénario: Le lien « Se connecter » mène à la page de connexion
    Quand je me rends sur la page d'accueil
    Et que je clique sur "Se connecter"
    Alors je suis sur la page de connexion
    Et la page contient "S’identifier avec ProConnect"

  Scénario: Le bouton « Contactez-nous » écrit au support DataPass
    Quand je me rends sur la page d'accueil
    Alors il y a un lien vers "mailto:datapass@api.gouv.fr"

  Scénario: Un utilisateur connecté qui ouvre l’accueil arrive sur son tableau de bord
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je me rends sur la page d'accueil
    Alors je suis sur mon tableau de bord
    Et la page ne contient pas "Habilitations et registre du portefeuille européen"

  Scénario: Un visiteur qui ouvre le lien d’une demande passe par la page de connexion
    Sachant que je suis un demandeur
    Et que j'ai 1 demande d'habilitation "API Entreprise" en brouillon
    Quand je me rends sur la page demandeur de cette demande
    Alors le titre de la page est "Connexion - DataPass"
    Et la page contient "S’identifier avec ProConnect"
