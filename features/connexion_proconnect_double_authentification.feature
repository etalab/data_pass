# language: fr

Fonctionnalité: Connexion ProConnect : double authentification obligatoire
  En tant qu’agent qui se connecte avec ProConnect, je dois avoir validé une double
  authentification, quel que soit mon fournisseur d’identité.

  Contexte:
    Sachant que je suis un demandeur

  Scénario: Connexion avec double authentification
    Quand je me connecte via ProConnect avec l'identité "Renater" qui renvoi l'organisation "DINUM"
    Alors je suis sur la page "Votre organisation de rattachement"

  Scénario: Connexion refusée sans double authentification
    Quand je me connecte via ProConnect avec l'identité "Renater" sans double authentification
    Alors il y a un message d'erreur contenant "sans avoir une double authentification installée"
    Et la page contient "S’identifier avec ProConnect"
