# language: fr

Fonctionnalité: Archiver une habilitation
  Un demandeur peut archiver une de ses habilitations en brouillon

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Le bouton "Archiver" est présent sur une habilitation m'appartenant en brouillon
    Quand je me rends sur une demande d'habilitation "API Entreprise" en brouillon
    Alors il y a un bouton "Archiver"

  Scénario: Le bouton "Archiver" n'est pas présent sur une habilitation m'appartenant validée
    Quand je me rends sur une demande d'habilitation "API Entreprise" validée
    Alors il n'y a pas de bouton "Archiver"

  Scénario: Le bouton "Archiver" n'est pas présent sur une habilitation de mon organisation en brouillon
    Quand mon organisation a 1 demande d'habilitation "API Entreprise" en brouillon
    Et que je clique sur "Les demandes ou habilitations de l'organisation"
    Et que je clique sur "Consulter"
    Alors il n'y a pas de bouton "Archiver"

  Scénario: J'archive une de mes habilitations en brouillon
    Quand je me rends sur une demande d'habilitation "API Entreprise" en brouillon
    Et que je clique sur "Archiver"
    Et que je clique sur "Archiver la demande"
    Alors je suis sur la page "Accueil"
    Et il y a un message de succès contenant "a été archivée"
