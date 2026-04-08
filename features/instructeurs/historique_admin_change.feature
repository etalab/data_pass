# language: fr

Fonctionnalité: Historique des modifications admin
  Les modifications effectuées par les administrateurs sont tracées dans l'historique

  @DisableBullet
  Scénario: Un demandeur voit la raison publique et le diff mais pas la raison privée
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand j'ai 1 demande d'habilitation "API Entreprise" en attente
    Et qu'un administrateur a effectué une modification avec la raison "Correction du titre du projet" et la raison privée "Ticket #SP-1234" et le diff suivant :
      | champ    | ancienne valeur                              | nouvelle valeur         |
      | intitule | Demande d'accès à la plateforme fournisseur | Nouveau titre du projet |
    Et que je me rends sur cette demande d'habilitation
    Et que je clique sur "Historique"
    Alors la page contient "a effectué une modification"
    Et la page contient "Correction du titre du projet"
    Et la page contient "Nouveau titre du projet"
    Et la page ne contient pas "Ticket #SP-1234"

  @DisableBullet
  Scénario: Un demandeur voit une modification admin sans diff
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand j'ai 1 demande d'habilitation "API Entreprise" en attente
    Et qu'un administrateur a effectué une modification avec la raison "Migration technique des données" et la raison privée "Déploiement v2.3"
    Et que je me rends sur cette demande d'habilitation
    Et que je clique sur "Historique"
    Alors la page contient "a effectué une modification"
    Et la page contient "Migration technique des données"
    Et la page ne contient pas "Déploiement v2.3"

  @DisableBullet
  Scénario: Un administrateur voit la raison privée dans l'historique
    Sachant que je suis un instructeur "API Entreprise"
    Et que je suis un administrateur
    Et que je me connecte
    Quand il y a 1 demande d'habilitation "API Entreprise" en attente
    Et qu'un administrateur a effectué une modification avec la raison "Correction du titre" et la raison privée "Ticket #SP-5678"
    Et que je me rends sur mon tableau de bord instructeur
    Et que je clique sur "Consulter"
    Et que je clique sur "Historique"
    Alors la page contient "a effectué une modification"
    Et la page contient "Correction du titre"
    Et la page contient "Ticket #SP-5678"
