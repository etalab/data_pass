# language: fr

Fonctionnalité: Connexion ProConnect: ajout d'une organisation
  En tant qu'utilisateur qui se connecte avec ProConnect avec un fournisseur d'identité qui me permet de choisir ou ajouter mon organisation de rattachement,
  je décide d'ajouter une nouvelle organisation de rattachement à mon compte.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte via ProConnect avec l'identité "DGFIP" qui renvoi l'organisation "DINUM"
    Et que je clique sur "Rejoindre une autre organisation"

  Scénario: Ajout d'une organisation valide
    Quand je remplis "Numéro de SIRET" avec "21920023500014"
    Et que je clique sur "Rechercher"
    Alors la page contient "CLAMART"

  Scénario: Rattachement à une organisation valide
    Quand je remplis "Numéro de SIRET" avec "21920023500014"
    Et que je clique sur "Rechercher"
    Et que je clique sur "Rejoindre l'organisation"
    Alors je suis sur la page "Demandes et habilitations"
    Et il y a un message de succès contenant "rattaché à votre compte"
    Et la page contient "CLAMART"
    Et l'organisation associée est marquée comme "non vérifiée"
    Et l'organisation associée est marquée comme "ajoutée manuellement"

  Scénario: Tentative d'ajout d'une organisation avec un siret invalide
    Quand je remplis "Numéro de SIRET" avec "12345676545678"
    Et que je clique sur "Rechercher"
    Alors il y a un message d'erreur contenant "Le numéro de SIRET n'est pas valide"

  @SiretInexistant
  Scénario: Tentative d'ajout d'une organisation avec un siret ayant un format valide mais non existant
    Quand je remplis "Numéro de SIRET" avec "55837874100737"
    Et que je clique sur "Rechercher"
    Alors il y a un message d'erreur contenant "n'existe pas dans le répertoire Sirene de l'INSEE"
