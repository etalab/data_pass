# language: fr

Fonctionnalité: Historique des modifications admin
  Les modifications effectuées par les administrateurs sont tracées dans l'historique

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  @DisableBullet
  Scénario: Je vois une modification admin avec un diff dans l'historique
    Quand j'ai 1 demande d'habilitation "API Entreprise" en attente
    Et qu'un administrateur a effectué une modification avec la raison "Correction du titre du projet" et le diff suivant :
      | champ    | ancienne valeur                              | nouvelle valeur         |
      | intitule | Demande d'accès à la plateforme fournisseur | Nouveau titre du projet |
    Et que je me rends sur cette demande d'habilitation
    Et que je clique sur "Historique"
    Alors la page contient "a effectué une modification"
    Et la page contient "Correction du titre du projet"
    Et la page contient "Nouveau titre du projet"

  @DisableBullet
  Scénario: Je vois une modification admin sans diff dans l'historique
    Quand j'ai 1 demande d'habilitation "API Entreprise" en attente
    Et qu'un administrateur a effectué une modification avec la raison "Migration technique des données"
    Et que je me rends sur cette demande d'habilitation
    Et que je clique sur "Historique"
    Alors la page contient "a effectué une modification"
    Et la page contient "Migration technique des données"
