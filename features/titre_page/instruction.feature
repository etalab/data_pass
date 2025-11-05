# language: fr

Fonctionnalité: Titres de page de l'espace instruction
  En tant qu'instructeur
  Je veux voir des titres de page pertinents pour les pages d'instruction
  Afin de pouvoir identifier facilement ces pages dans l'historique et les onglets

  Scénario: Le titre de la page d'instruction d'une demande est Instruction API Entreprise - nom de la demande - DataPass
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte
    Et il y a 1 demande d'habilitation "API Entreprise" soumise
    Quand je me rends sur cette demande d'habilitation
    Alors le titre de la page contient "Instruction API Entreprise - Demande d'accès à la plateforme fournisseur - DataPass"
