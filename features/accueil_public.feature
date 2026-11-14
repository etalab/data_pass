# language: fr

Fonctionnalité: Accueil public
  En tant que visiteur, je comprends à quoi sert DataPass
  et je trouve la démarche qui me concerne.

  Scénario: Un visiteur déconnecté voit l’en-tête public, le bandeau et les trois tuiles
    Quand je me rends sur la page d'accueil
    Alors l'en-tête contient "Habilitations et registre du portefeuille européen"
    Et l'en-tête contient le lien "Accueil"
    Et l'en-tête contient le lien "Portefeuille européen"
    Et l'en-tête contient le lien "Se connecter"
    Et la page contient "Le registre des parties utilisatrices du portefeuille européen ouvre le 24 décembre 2026."
    Et je vois 3 tuiles
    Et il y a un badge "Nouveau"

  @registre_ouvert
  Scénario: Une fois le registre ouvert, l’accueil n’annonce plus son ouverture
    Sachant que le registre du portefeuille européen est ouvert
    Quand je me rends sur la page d'accueil
    Alors l’accueil n’affiche pas de bandeau d’information
    Et je vois 3 tuiles

  Scénario: Chaque tuile mène à sa section ou à la page Portefeuille européen
    Quand je me rends sur la page d'accueil
    Alors la tuile "Vous cherchez des données pour votre service" mène à "#acceder"
    Et la tuile "Vous êtes une administration qui détient des données" mène à "#administrations"
    Et la tuile "Votre organisation et le portefeuille européen" mène à "/portefeuille-europeen"

  @javascript
  Scénario: Deux clics sur une tuile mènent à sa section sans recharger la page
    Quand je me rends sur la page d'accueil
    Et que je compte les visites Turbo
    Et que je clique deux fois sur la tuile "Vous cherchez des données pour votre service"
    Alors l'adresse se termine par "#acceder"
    Et Turbo n'a lancé aucune visite

  Scénario: Le lien « Se connecter » mène à la page de connexion
    Quand je me rends sur la page d'accueil
    Et que je clique sur "Se connecter"
    Alors je suis sur la page de connexion
    Et la page contient "S’identifier avec ProConnect"

  Scénario: Un visiteur déconnecté garde l’en-tête public sur la page de connexion
    Quand je me rends sur la page de connexion
    Alors l'en-tête contient le lien "Portefeuille européen"
    Et l'en-tête contient le lien "Se connecter"

  Scénario: Le bouton « Contactez-nous » écrit au support DataPass
    Quand je me rends sur la page d'accueil
    Alors la page contient un lien "Contactez-nous" vers "mailto:datapass@api.gouv.fr"

  Scénario: Un utilisateur connecté qui ouvre l’accueil arrive sur son tableau de bord
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je me rends sur la page d'accueil
    Alors je suis sur mon tableau de bord
    Et l'en-tête ne contient pas le lien "Se connecter"
    Et l'en-tête ne contient pas le lien "Portefeuille européen"

  Scénario: Un visiteur sur un sous-domaine fournisseur garde l’en-tête du fournisseur
    Sachant que je consulte le site ayant le sous-domaine "api-entreprise"
    Quand je me rends sur la page de connexion
    Alors l'en-tête ne contient pas le lien "Portefeuille européen"
    Et l'en-tête ne contient pas le lien "Se connecter"

  Scénario: Un visiteur qui ouvre le lien d’une demande passe par la page de connexion
    Sachant que je suis un demandeur
    Et que j'ai 1 demande d'habilitation "API Entreprise" en brouillon
    Quand je me rends sur la page demandeur de cette demande
    Alors le titre de la page est "Connexion - DataPass"
    Et la page contient "S’identifier avec ProConnect"
