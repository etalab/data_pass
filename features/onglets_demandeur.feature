# language: fr

Fonctionnalité: Visibilité des onglets sur les pages demandeur
  Les onglets Historique et Messagerie sont visibles selon le profil de l'utilisateur.

  Scénario: Un demandeur voit tous les onglets sur sa demande
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand j'ai 1 demande d'habilitation "API Entreprise" soumise
    Et que je me rends sur cette demande d'habilitation
    Alors je vois l'onglet "Demande"
    Et je vois l'onglet "Historique"
    Et je vois l'onglet "Messagerie"

  Scénario: Un demandeur voit tous les onglets sur son habilitation
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand j'ai 1 habilitation "API Entreprise" active
    Et je visite la page de mon habilitation
    Alors je vois l'onglet "Habilitation"
    Et je vois l'onglet "Historique"
    Et je vois l'onglet "Messagerie"
    Et je vois l'onglet "Toutes les habilitations"

  Scénario: Un demandeur voit le message automatique pour une habilitation auto-générée
    Sachant que je suis un demandeur
    Et que je me connecte
    Sachant que j'ai une demande API Particulier avec champs FranceConnect intégrés validée
    Et je visite la page de mon habilitation
    Et que je clique sur "Toutes les habilitations"
    Alors la page contient "Habilitation FranceConnect automatiquement délivrée"
    Et la page contient "Habilitation API Particulier"

  Scénario: Un membre de l'organisation voit tous les onglets sur une demande de son organisation
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand mon organisation a 1 demande d'habilitation "API Entreprise" soumise
    Et que je me rends sur mon tableau de bord demandes
    Et que je clique sur "Consulter"
    Alors je vois l'onglet "Demande"
    Et je vois l'onglet "Historique"
    Et je vois l'onglet "Messagerie"

  Scénario: Un contact désigné ne voit pas les onglets Historique et Messagerie
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand je suis mentionné dans 1 demande d'habilitation "API Entreprise" en tant que "Contact technique"
    Et que je me rends sur mon tableau de bord demandes
    Et que je clique sur "Consulter"
    Alors je vois l'onglet "Demande"
    Et je ne vois pas l'onglet "Historique"
    Et je ne vois pas l'onglet "Messagerie"

  Scénario: Un rapporteur voit tous les onglets sur la page demandeur d'une demande
    Sachant que je suis un rapporteur "API Entreprise"
    Et que je me connecte
    Quand une autre organisation a 1 demande d'habilitation "API Entreprise" soumise
    Et que je me rends sur la page demandeur de cette demande
    Alors je vois l'onglet "Demande"
    Et je vois l'onglet "Historique"
    Et je vois l'onglet "Messagerie"

  Scénario: Un rapporteur voit tous les onglets sur la page demandeur d'une habilitation
    Sachant que je suis un rapporteur "API Entreprise"
    Et que je me connecte
    Quand une autre organisation a 1 habilitation "API Entreprise" active
    Et que je me rends sur la page demandeur de cette habilitation
    Alors je vois l'onglet "Habilitation"
    Et je vois l'onglet "Historique"
    Et je vois l'onglet "Messagerie"
    Et je vois l'onglet "Toutes les habilitations"

  Scénario: Un instructeur voit tous les onglets sur la page demandeur d'une demande
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte
    Quand une autre organisation a 1 demande d'habilitation "API Entreprise" soumise
    Et que je me rends sur la page demandeur de cette demande
    Alors je vois l'onglet "Demande"
    Et je vois l'onglet "Historique"
    Et je vois l'onglet "Messagerie"

  Scénario: Un instructeur voit tous les onglets sur la page demandeur d'une habilitation
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte
    Quand une autre organisation a 1 habilitation "API Entreprise" active
    Et que je me rends sur la page demandeur de cette habilitation
    Alors je vois l'onglet "Habilitation"
    Et je vois l'onglet "Historique"
    Et je vois l'onglet "Messagerie"
    Et je vois l'onglet "Toutes les habilitations"
