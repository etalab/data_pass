# language: fr

Fonctionnalité: Liste des cas d'usage d'un formulaire
  En tant qu'instructeur, je peux consulter la liste des cas d'usage
  d'un formulaire afin de voir les différentes déclinaisons disponibles.

  Contexte:
    Soit un fournisseur de données "DINUM" existe
    Sachant que je suis un rapporteur "API Entreprise"
    Et que je me connecte

  Scénario: Je peux accéder à la liste des cas d'usage depuis le détail d'un formulaire
    Quand je me rends sur le formulaire "API Entreprise"
    Et je clique sur "Voir les cas d'usage"
    Alors la page contient "Cas d'usage"
    Et la page contient "Marchés publics"
    Et la page contient "Aides publiques"

  Scénario: Les compteurs de demandes sont affichés sur chaque cas d'usage
    Sachant qu'il y a 2 demandes d'habilitation "API Entreprise" via le formulaire "Marchés publics" validées
    Et qu'il y a 1 demande d'habilitation "API Entreprise" via le formulaire "Marchés publics" en attente
    Quand je me rends sur la liste des cas d'usage de "API Entreprise"
    Alors le cas d'usage "Marchés publics" affiche 2 demandes validées et 1 demande en cours

  Scénario: Le formulaire par défaut est listé dans les cas d'usage
    Quand je me rends sur la liste des cas d'usage de "API Entreprise"
    Alors la page contient "Demande libre"

  Scénario: Le nombre total de cas d'usage est affiché
    Quand je me rends sur la liste des cas d'usage de "API Entreprise"
    Alors la page contient le nombre de cas d'usage de "API Entreprise"

