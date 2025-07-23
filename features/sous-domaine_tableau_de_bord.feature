# language: fr

Fonctionnalité: Tableau de bord pour un sous-domaine spécifique
  Cette page est la page principale de l'utilisateur, où il peut voir les diverses actions
  qu'il doit effectuer. Cette version du tableau de bord est restreinte à un sous-ensemble d'habilitations
  régie par le sous-domaine

  Contexte:
    Sachant que je suis un demandeur
    Et que je consulte le site ayant le sous-domaine "api-entreprise"
    Et que je me connecte

  Scénario: Je vois sur l'écran principal l'ensemble de mes habilitations uniquement lié au sous-domaine, quelque soit leur état
    Quand j'ai 1 demande d'habilitation "API Entreprise" en brouillon
    Et j'ai 1 demande d'habilitation "API Entreprise" en attente
    Et j'ai 1 demande d'habilitation "API Entreprise" refusée
    Et j'ai 1 demande d'habilitation "API Entreprise" validée
    Et j'ai 1 demande d'habilitation "API Particulier" validée
    Et que mon organisation a 1 demande d'habilitation "API Entreprise"
    Et que je me rends sur mon tableau de bord demandes
    Alors je vois 3 demandes d'habilitation
    Et la page contient "vous êtes le demandeur"
    Et que je me rends sur mon tableau de bord habilitations
    Alors je vois 1 habilitations
    Et la page contient "vous êtes le demandeur"
