# language: fr

Fonctionnalité: Instruction: liste des habilitations en tant que rapporteur
  Un rapporteur peut se rendre sur l'espace d'instruction et consulter les demandes
  dont il doit effectuer la modération.

  Contexte:
    Sachant que je suis un rapporteur "API Entreprise"
    Et que je me connecte

  Scénario: Je vois les habilitations dont je suis rapporteur
    Sachant qu'il y a 2 demandes d'habilitation "API Entreprise" en attente
    Et qu'il y a 1 demande d'habilitation "Portail HubEE - Démarche CertDC" en attente
    Et que je vais sur la page instruction
    Alors je vois 2 demandes d'habilitation

  Scénario: Je vois les badges des habilitations en réouvertures
    Sachant qu'il y a 1 demande d'habilitation "API Entreprise" réouverte
    Et que je vais sur la page instruction
    Alors il y a un badge "Brouillon"
    Et il y a un badge "Mise à jour"

  Scénario: Je cherche une habilitation avec son status
    Sachant qu'il y a 1 demande d'habilitation "API Entreprise" en attente
    Et qu'il y a 1 demande d'habilitation "API Entreprise" validée
    Et que je vais sur la page instruction
    Et que je sélectionne "Validée" pour "État égal à"
    Et que je clique sur "Rechercher"
    Alors je vois 1 demande d'habilitation
