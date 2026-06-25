# language: fr

Fonctionnalité: Liste des formulaires pour les instructeurs
  En tant qu'instructeur, je peux consulter la liste des formulaires
  auxquels j'ai accès, afin de gérer mes habilitations.

  Contexte:
    Soit un fournisseur de données "DINUM" existe
    Sachant que je suis un rapporteur "API Entreprise"
    Et que je me connecte

  Scénario: Je vois le lien vers la liste des formulaires dans l'espace instruction
    Quand je me rends sur mon tableau de bord instructeur
    Alors il y a un bouton "Formulaires"

  Scénario: Je peux accéder à la liste des formulaires
    Quand je me rends sur la liste des formulaires
    Alors la page contient "API Entreprise"

  Scénario: Je ne vois que les formulaires pour lesquels j'ai un rôle
    Quand je me rends sur la liste des formulaires
    Alors la page contient "API Entreprise"
    Et la page ne contient pas "API Particulier"

  Scénario: Les compteurs de demandes affichés sur un formulaire sont corrects
    Sachant qu'il y a 2 demandes d'habilitation "API Entreprise" validées
    Et qu'il y a 1 demande d'habilitation "API Entreprise" en attente
    Quand je me rends sur la liste des formulaires
    Alors le formulaire "API Entreprise" affiche 2 demandes validées et 1 demande en cours

  Scénario: La description affiche le fournisseur de données
    Quand je me rends sur la liste des formulaires
    Alors la page contient "DINUM"
