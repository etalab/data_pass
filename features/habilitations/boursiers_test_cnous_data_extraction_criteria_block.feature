# language: fr

@cnous_data_extraction_criteria @javascript
Fonctionnalité: Soumission d'une demande Boursiers CNOUS avec le bloc cnous_data_extraction_criteria

  Scénario: Je soumets une demande Boursiers CNOUS valide
    Sachant que je suis un demandeur
    Et que je me connecte
    Et qu'un type d'habilitation "Boursiers" expose le bloc "cnous_data_extraction_criteria"

    Quand je démarre une nouvelle demande d'habilitation "Boursiers"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je clique sur "Ajouter une commune"
    * je remplis "Communes (codes INSEE) n°1" avec "75056"
    * je remplis "Communes (codes INSEE) n°2" avec "69123"
    * je sélectionne "Échelon 5 et au-dessus" pour "Échelon de bourse minimum"
    * je remplis "Première date de transmission" avec "2026-09-01"
    * je sélectionne "Annuelle" pour "Récurrence"
    * je clique sur "Suivant"

    * je clique sur "Précédent"
    * le bouton de suppression de la commune "75056" est annoncé par son code aux lecteurs d’écran
    * chaque champ commune INSEE est annoncé avec sa position aux lecteurs d’écran
    * je clique sur "Suivant"

    * je renseigne les informations du contact technique
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et la demande contient les conditions d'extraction CNOUS attendues

  Scénario: Le formulaire accepte les codes INSEE Corse et à zéro de tête
    Sachant que je suis un demandeur
    Et que je me connecte
    Et qu'un type d'habilitation "Boursiers" expose le bloc "cnous_data_extraction_criteria"

    Quand je démarre une nouvelle demande d'habilitation "Boursiers"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je clique sur "Ajouter une commune"

    Alors les champs de codes INSEE acceptent les caractères alphanumériques de longueur 5
    Et le groupe de codes INSEE utilise la légende DSFR conforme

    Quand je remplis "Communes (codes INSEE) n°1" avec "2A004"
    Et je remplis "Communes (codes INSEE) n°2" avec "01001"
    Et je sélectionne "Échelon 5 et au-dessus" pour "Échelon de bourse minimum"
    Et je remplis "Première date de transmission" avec "2026-09-01"
    Et je sélectionne "Annuelle" pour "Récurrence"
    Et je clique sur "Suivant"

    * je renseigne les informations du contact technique
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et la demande contient les codes communes INSEE "2A004" et "01001"

  Scénario: Le focus est géré au clavier dans la liste des communes
    Sachant que je suis un demandeur
    Et que je me connecte
    Et qu'un type d'habilitation "Boursiers" expose le bloc "cnous_data_extraction_criteria"

    Quand je démarre une nouvelle demande d'habilitation "Boursiers"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    Quand je clique sur "Ajouter une commune"
    Alors le focus est sur le dernier champ commune INSEE

    Quand je clique sur le bouton de suppression du dernier champ ajouté
    Alors le focus est sur le bouton "Ajouter une commune"
