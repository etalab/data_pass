# language: fr

Fonctionnalité: Développeurs: consultation de ses applications
  En tant que développeur
  Je veux consulter mes applications
  Afin de pouvoir récupérer mes identifiants

  Contexte:
    Sachant que je suis un développeur "API Entreprise"
    Et que je me connecte
  
  Scénario: Je peux voir que je suis developpeur dans mon profil
    Quand je me rends sur le chemin "/compte"
    Alors la page contient "Vous avez un accès développeur"
    Et il y a un lien vers "/developpeurs/applications"
    Et il y a un lien vers "/developpeurs/documentation"

  Scénario: Je peux voir mon application
    Quand je me rends sur le chemin "/developpeurs/applications"
    Alors la page contient "Mes credentials API"
    Et la page contient "Accès API Entreprise"
    Et la page contient "Secret: ****ecret"
    Et il y a un bouton "Copier"
    Et la page contient "Vos credentials API vous permettent d'accéder aux demandes et habilitations suivantes :"
    Et la page contient "api_entreprise"
