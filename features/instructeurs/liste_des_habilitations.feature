# language: fr

Fonctionnalité: Instruction: liste des habilitations
  Un instructeur peut se rendre sur l'espace d'instruction et consulter les demandes
  dont il doit effectuer la modération.

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte

  Scénario: Je vois les habilitations dont je suis instructeur
    Sachant qu'il y a 2 demandes d'habilitation "API Entreprise" en attente
    Et qu'il y a 1 demande d'habilitation "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)" en attente
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

  Scénario: Je peux filtrer les habilitations archivés
    Sachant qu'il y a 1 demande d'habilitation "API Entreprise" en attente
    Et qu'il y a 1 demande d'habilitation "API Entreprise" archivée
    Et que je vais sur la page instruction
    Et que je sélectionne "Archivée" pour "État égal à"
    Et que je clique sur "Rechercher"
    Alors je vois 1 demande d'habilitation

  Scénario: Trier par date de soumission fonctionne
    Sachant qu'il y a 1 demande d'habilitation "API Entreprise" en attente
    Et que je vais sur la page instruction
    Et que je clique sur "Dernière date de soumission"
    Alors je vois 1 demande d'habilitation

  Scénario: Trier par statut fonctionne
    Sachant qu'il y a 1 demande d'habilitation "API Entreprise" en attente
    Et que je vais sur la page instruction
    Et que je clique sur "Statut"
    Alors je vois 1 demande d'habilitation

