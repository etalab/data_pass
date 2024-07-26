# language: fr

Fonctionnalité: Modifications d'un formulaire depuis sa page de résumé
  Chaque bloc éditable d'un formulaire peut être modifié depuis sa page de résumé.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Et que je me rends sur une demande d'habilitation "Solution Portail des aides" en brouillon
    Et que je renseigne les informations des contacts RGPD
    Et que je clique sur "Continuer vers le résumé"

  Scénario: Les blocs fixes n'ont pas de bouton modifier
    Alors il n'y a pas de lien "Modifier" dans le bloc de résumé "Mon projet"
    Et il y a un lien "Modifier" dans le bloc de résumé "Les personnes impliquées"

  Scénario: Le titre du bloc s'affiche lorsque l'on édite un bloc
    Quand je clique sur "Modifier" dans le bloc de résumé "Les personnes impliquées"
    Alors la page contient "Quelles sont les personnes impliquées ?"

  Scénario: Modification avec des données valides
    Quand je clique sur "Modifier" dans le bloc de résumé "Les personnes impliquées"
    Et que je remplis les informations du contact "Responsable de traitement" avec :
      | Nom     | Prénom | Email                 | Téléphone  | Fonction                  |
      | Nouveau | Louis  | nouveau.louis@gouv.fr | 0836656560 | Directeur d'exploitation  |
    Et que je clique sur "Enregistrer les modifications"
    Alors il y a un message de succès contenant "été sauvegardé"
    Et la page contient "Récapitulatif de votre demande"

  Scénario: Modification avec des données invalides
    Quand je clique sur "Modifier" dans le bloc de résumé "Les personnes impliquées"
    Et que je remplis les informations du contact "Responsable de traitement" avec :
      | Nom     | Prénom | Email                 | Téléphone  | Fonction                  |
      |         | Louis  | nouveau.louis@gouv.fr | 0836656560 | Directeur d'exploitation  |
    Et que je clique sur "Enregistrer les modifications"
    Alors il y a un message d'erreur contenant "lors de la sauvegarde"
