# language: fr

Fonctionnalité: Connexion à DataPass
  Scénario: Je me connecte au service via ProConnect FI (ex-MCP)
    Sachant que je suis un demandeur
    Et que je me connecte
    Alors je suis sur la page "Demandes et habilitations"
    Et la page contient "DUPONT Jean"
    Et il y a un message de succès contenant "Vous êtes connecté"

  Scénario: Je me connecte au service via ProConnect
    Sachant que je suis un demandeur
    Et que je me connecte via ProConnect
    Alors je suis sur la page "Demandes et habilitations"
    Et la page contient "DUPONT Jean"
    Et il y a un message de succès contenant "Vous êtes connecté"
