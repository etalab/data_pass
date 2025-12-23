# language: fr

Fonctionnalité: Instruction: liste des habilitations
  Un instructeur peut se rendre sur l'espace d'instruction et consulter les habilitations
  dont il a effectué la modération.

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte

  Scénario: Je vois les habilitations dont je suis instructeur
    Sachant qu'il y a 2 habilitations "API Entreprise" actives
    Et qu'il y a 1 habilitation "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)" active
    Et que je me rends sur mon tableau de bord instructeur habilitations
    Alors je vois 2 habilitations
    Et la page contient "2 résultats"

  @javascript
  Scénario: Je cherche une habilitation avec son status
    Sachant qu'il y a 1 habilitation "API Entreprise" active
    Et qu'il y a 1 habilitation "API Entreprise" révoquée
    Et que je vais sur la page instruction
    Et que je me rends sur mon tableau de bord instructeur habilitations
    Et que je sélectionne "Révoquée" dans le multi-select "Statut"
    Et que je clique sur "Rechercher"
    Alors je vois 1 habilitation

  @javascript
  Scénario: Je peux filtrer par plusieurs statuts
    Sachant qu'il y a 2 habilitations "API Entreprise" actives
    Et qu'il y a 1 habilitation "API Entreprise" révoquée
    Et qu'il y a 1 habilitation "API Entreprise" obsolète
    Et que je me rends sur mon tableau de bord instructeur habilitations
    Et que je sélectionne "Active" dans le multi-select "Statut"
    Et que je sélectionne "Révoquée" dans le multi-select "Statut"
    Et que je clique sur "Rechercher"
    Alors je vois 3 habilitations

  @javascript
  Scénario: Je peux réinitialiser les filtres de statut
    Sachant qu'il y a 2 habilitations "API Entreprise" actives
    Et qu'il y a 1 habilitation "API Entreprise" révoquée
    Et que je me rends sur mon tableau de bord instructeur habilitations
    Et que je sélectionne "Active" dans le multi-select "Statut"
    Et que je clique sur "Rechercher"
    Alors je vois 2 habilitations
    Et que je réinitialise le multi-select "Statut"
    Et que je clique sur "Rechercher"
    Alors je vois 3 habilitations

  @javascript
  Scénario: Je peux combiner les filtres de type et de statut
    Sachant que je suis un instructeur avec plusieurs types d'autorisation
    Et qu'il y a 2 habilitations "API Entreprise" actives
    Et qu'il y a 1 habilitation "API Particulier" active
    Et qu'il y a 1 habilitation "API Entreprise" révoquée
    Et que je me rends sur mon tableau de bord instructeur habilitations
    Et que je sélectionne "API Entreprise" dans le multi-select "Type d'habilitation"
    Et que je sélectionne "Active" dans le multi-select "Statut"
    Et que je clique sur "Rechercher"
    Alors je vois 2 habilitations

  Scénario: Trier par date de création fonctionne
    Sachant qu'il y a 1 habilitation "API Entreprise" active
    Et que je me rends sur mon tableau de bord instructeur habilitations
    Et que je clique sur "Date de création"
    Alors je vois 1 habilitation

  Scénario: Trier par statut fonctionne
    Sachant qu'il y a 1 habilitation "API Entreprise" révoquée
    Et que je me rends sur mon tableau de bord instructeur habilitations
    Et que je clique sur "Statut"
    Alors je vois 1 habilitation
  
  Scénario: La pagination limite le nombre de résultats mais compte bien le nombre total de résultats
    Sachant qu'il y a 26 habilitations "API Entreprise" actives
    Et que je me rends sur mon tableau de bord instructeur habilitations
    Alors je vois 25 habilitations
    Et la page contient "26 résultats"

