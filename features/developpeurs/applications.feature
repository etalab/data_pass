# language: fr

Fonctionnalité: Développeurs: consultation de ses applications
  En tant que développeur
  Je veux consulter mes applications
  Afin de pouvoir récupérer mes identifiants

  Contexte:
    Sachant que je suis un développeur "API Entreprise"
    Et que je me connecte
  
  Scénario: Je peux voir mon application
    Quand je me rends sur le chemin "/developpeurs/applications"
    Alors la page contient "Mes applications"
    Et la page contient "Accès API Entreprise"
    Et la page contient "Secret: ****ecret"
    Et il y a un bouton "Copier"
