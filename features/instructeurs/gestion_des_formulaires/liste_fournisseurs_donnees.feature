# language: fr

Fonctionnalité: Liste des fournisseurs de données pour les instructeurs
  En tant qu'instructeur, je peux consulter la liste des fournisseurs de données
  dont je suis en charge, afin de gérer mes formulaires.

  Contexte:
    Soit un fournisseur de données "DINUM" existe
    Sachant que je suis un rapporteur "API Entreprise"
    Et que je me connecte

  Scénario: Je peux accéder à la liste des fournisseurs de données
    Quand je me rends sur la liste des formulaires
    Alors la page contient "DINUM"

  Scénario: Je vois le lien vers les formulaires dans le menu de navigation
    Quand je me rends sur mon tableau de bord instructeur
    Alors le menu de navigation contient "Formulaires"

  Scénario: Je ne vois que les fournisseurs de données pour lesquels j'ai un rôle
    Soit un fournisseur de données "CNAM" existe
    Et un fournisseur de données "DGFIP" existe
    Et je suis un rapporteur "API Indemnités Journalières de la CNAM"
    Quand je me rends sur la liste des formulaires
    Alors la page contient "DINUM"
    Et la page contient "CNAM"
    Et la page ne contient pas "DGFIP"

