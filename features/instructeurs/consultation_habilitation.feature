# language: fr

Fonctionnalité: Instruction: consultation d'une demande d'habilitation
  Un instructeur peut consulter une demande d'habilitation et y voir des informations relatives aux entités

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je suis un instructeur "API Impôt Particulier"
    Et que je me connecte

  Scénario: Je vois les informations sur l'organisation et le demandeur
    Quand je me rends sur une demande d'habilitation "API Entreprise" de l'organisation "Ville de Clamart" en brouillon
    Alors la page contient "COMMUNE DE CLAMART"
    Et la page contient "1 PL MAURICE GUNSBOURG"
    Et la page contient "92140 CLAMART"
    Et la page contient "DUPONT Jean"
    Et la page contient "Adjoint au Maire"

  Scénario: Je vois un bouton pour consulter l'habilitation validée d'une demande de réouverture
    Quand je me rends sur une demande d'habilitation "API Entreprise" réouverte
    Alors il y a un bouton "Consulter l'habilitation"

  Scénario: Je ne vois pas d'onglet pour consulter les habilitations d'une demande sans habilitation
    Quand je me rends sur une demande d'habilitation "API Entreprise" en brouillon
    Alors la page ne contient pas "Toutes les habilitations"

  Scénario: Je vois un onglet pour consulter les habilitations d'une demande validée
    Quand je me rends sur une demande d'habilitation "API Entreprise" validée
    Et que je clique sur "Toutes les habilitations"
    Alors la page contient "Historique des habilitations liées à cette demande"

  Scénario: Je peux naviguer d'une demande validée à une habilitation et revenir sur la demande
    Quand je me rends sur une demande d'habilitation "API Entreprise" validée
    Et que je clique sur "Toutes les habilitations"
    Et que je clique sur "Consulter l'habilitation"
    Alors la page contient "Cette habilitation est liée à la demande N°"
    Et que je clique sur "demande N°"
    Alors la page contient "Toutes les habilitations"

  Scénario: Je vois les habilitations de sandbox et production d'une demande DGFiP validée
    Quand je me rends sur une demande d'habilitation "API Impôt Particulier" validée
    Et que je clique sur "Toutes les habilitations"
    Alors la page contient "Bac à sable"
    Et la page contient "Production"

  Scénario: Je ne vois pas de mention de production dans le titre d'une habilitation sandbox
    Quand je me rends sur une demande d'habilitation "API Impôt Particulier" validée
    Et que je clique sur "Toutes les habilitations"
    Et que je clique sur le dernier "Consulter l'habilitation"
    Alors la page ne contient pas "Production"

  Scénario: Je ne vois pas de bouton "Démarrer ma demande d’habilitation en production" sur une habilitation sandbox
    Quand je me rends sur une demande d'habilitation "API Impôt Particulier" validée
    Et que je clique sur "Toutes les habilitations"
    Et que je clique sur le dernier "Consulter l'habilitation"
    Et la page ne contient pas "Démarrer ma demande d’habilitation en production"