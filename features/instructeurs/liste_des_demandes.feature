# language: fr

Fonctionnalité: Instruction: liste des demandes
  Un instructeur peut se rendre sur l'espace d'instruction et consulter les demandes
  dont il doit effectuer la modération.

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte

  Scénario: Je vois les demandes dont je suis instructeur
    Sachant qu'il y a 2 demandes d'habilitation "API Entreprise" en attente
    Et qu'il y a 1 demande d'habilitation "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)" en attente
    Et que je vais sur la page instruction
    Alors je vois 2 demandes d'habilitation
    Et la page contient "2 résultats"

  Scénario: Je vois les badges des demandes en réouvertures
    Sachant qu'il y a 1 demande d'habilitation "API Entreprise" réouverte
    Et que je vais sur la page instruction
    Alors il y a un badge "Brouillon"
    Et il y a un badge "Mise à jour"
    Et la page contient "1 résultat"

  @javascript
  Scénario: Je cherche une demande avec son status
    Sachant qu'il y a 1 demande d'habilitation "API Entreprise" en attente
    Et qu'il y a 1 demande d'habilitation "API Entreprise" validée
    Et que je vais sur la page instruction
    Et que je sélectionne "En cours d'instruction" dans le multi-select "Statut"
    Et que je clique sur "Rechercher"
    Alors je vois 1 demande d'habilitation

  @javascript
  Scénario: Je peux filtrer les demandes archivés
    Sachant qu'il y a 1 demande d'habilitation "API Entreprise" en attente
    Et qu'il y a 1 demande d'habilitation "API Entreprise" archivée
    Et que je vais sur la page instruction
    Et que je sélectionne "Supprimée" dans le multi-select "Statut"
    Et que je clique sur "Rechercher"
    Alors je vois 1 demande d'habilitation

  @javascript
  Scénario: Je peux filtrer par plusieurs statuts
    Sachant qu'il y a 2 demandes d'habilitation "API Entreprise" en attente
    Et qu'il y a 1 demande d'habilitation "API Entreprise" en brouillon
    Et qu'il y a 1 demande d'habilitation "API Entreprise" refusée
    Et que je vais sur la page instruction
    Et que je sélectionne "En cours d'instruction" dans le multi-select "Statut"
    Et que je sélectionne "Brouillon" dans le multi-select "Statut"
    Et que je clique sur "Rechercher"
    Alors je vois 3 demandes d'habilitation

  @javascript
  Scénario: Je peux réinitialiser les filtres de statut
    Sachant qu'il y a 2 demandes d'habilitation "API Entreprise" en attente
    Et qu'il y a 1 demande d'habilitation "API Entreprise" en brouillon
    Et que je vais sur la page instruction
    Et que je sélectionne "En cours d'instruction" dans le multi-select "Statut"
    Et que je clique sur "Rechercher"
    Alors je vois 2 demandes d'habilitation
    Et que je réinitialise le multi-select "Statut"
    Et que je clique sur "Rechercher"
    Alors je vois 3 demandes d'habilitation

  @javascript
  Scénario: Je peux combiner les filtres de type et de statut
    Sachant que je suis un instructeur avec plusieurs types d'autorisation
    Et qu'il y a 2 demandes d'habilitation "API Entreprise" en attente
    Et qu'il y a 1 demande d'habilitation "API Particulier" en attente
    Et qu'il y a 1 demande d'habilitation "API Entreprise" en brouillon
    Et que je vais sur la page instruction
    Et que je sélectionne "API Entreprise" dans le multi-select "Type de demande"
    Et que je sélectionne "En cours d'instruction" dans le multi-select "Statut"
    Et que je clique sur "Rechercher"
    Alors je vois 2 demandes d'habilitation

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
  
  Scénario: La pagination limite le nombre de résultats mais compte bien le nombre total de résultats
    Sachant qu'il y a 26 demandes d'habilitation "API Entreprise" en attente
    Et que je vais sur la page instruction
    Alors je vois 25 demandes d'habilitation
    Et la page contient "26 résultats"

