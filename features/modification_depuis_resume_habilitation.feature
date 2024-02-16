# language: fr

Fonctionnalité: Modifications d'un formulaire depuis sa page de résumé
  Chaque bloc éditable d'un formulaire peut être modifié depuis sa page de résumé.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Et que je me rends sur une demande d'habilitation "Solution Portail des aides de l'éditeur MGDIS" en brouillon
    Et que je renseigne les informations des contacts RGPD
    Et que je clique sur "Enregistrer les modifications"
    Et que je clique sur "Continuer vers le résumé"

  Scénario: Les blocs fixes n'ont pas de bouton modifier
    Alors il n'y a pas de lien "Modifier" dans le bloc de résumé "Informations de base"
    Et il y a un lien "Modifier" dans le bloc de résumé "Contacts"

  Scénario: Modification avec des données valides
    Quand je clique sur "Modifier" dans le bloc de résumé "Contacts"
    Et que je remplis les informations du contact "Responsable de traitement" avec :
      | Nom     | Prénom | Email                 | Téléphone  | Fonction                  |
      | Nouveau | Louis  | nouveau.louis@gouv.fr | 0836656560 | Directeur d'exploitation  |
    Et que je clique sur "Enregistrer les modifications"
    Alors il y a un message de succès contenant "été mise à jour avec succès"
    Et la page contient "Récapitulatif de votre demande"

  Scénario: Modification avec des données invalides
    Quand je clique sur "Modifier" dans le bloc de résumé "Contacts"
    Et que je remplis les informations du contact "Responsable de traitement" avec :
      | Nom     | Prénom | Email                 | Téléphone  | Fonction                  |
      |         | Louis  | nouveau.louis@gouv.fr | 0836656560 | Directeur d'exploitation  |
    Et que je clique sur "Enregistrer les modifications"
    Alors il y a un message d'erreur contenant "lors de la mise à jour de la demande"
