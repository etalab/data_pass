# language: fr

@javascript
Fonctionnalité: Soumission d'une demande Boursiers CNOUS avec le bloc cnous_data_extraction_criteria

  Scénario: Je soumets une demande Boursiers CNOUS valide
    Sachant que je suis un demandeur
    Et que l’API géo connaît la commune "75056" nommée "Paris"
    Et que l’API géo connaît la commune "69123" nommée "Lyon"
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
    * je clique sur "Suivant"
    * la page contient "Contact technique"

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

  Scénario: Une collectivité identifiée comme commune voit son périmètre pré-rempli en lecture seule
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Et qu'un type d'habilitation "Boursiers" expose le bloc "cnous_data_extraction_criteria"

    Quand je démarre une nouvelle demande d'habilitation "Boursiers"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    Alors je vois le périmètre géographique en lecture seule contenant "Clamart"
    Et le périmètre indique que les informations ne sont pas modifiables
    Et le périmètre ne propose pas de voir toutes les communes

    Quand je sélectionne "Échelon 5 et au-dessus" pour "Échelon de bourse minimum"
    Et je remplis "Première date de transmission" avec "2026-09-01"
    Et je clique sur "Suivant"

    * je renseigne les informations du contact technique
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et la demande contient le code commune INSEE "92023"

  Scénario: Une collectivité identifiée comme département voit ses communes à la demande
    Sachant que je suis un demandeur du département du Rhône
    Et que l’API géo connaît la commune "69123" nommée "Lyon"
    Et que je me connecte
    Et qu'un type d'habilitation "Boursiers" expose le bloc "cnous_data_extraction_criteria"

    Quand je démarre une nouvelle demande d'habilitation "Boursiers"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    Alors je vois le périmètre géographique en lecture seule contenant "Rhône"
    Et le périmètre indique que les informations ne sont pas modifiables
    Et le résumé du périmètre est annoncé aux lecteurs d’écran

    Quand je clique sur "Voir toutes les communes"
    Alors je vois le périmètre géographique en lecture seule contenant "Villeurbanne"
    Et la liste des communes est annoncée par son libellé aux lecteurs d’écran
    Et le focus est sur la liste des communes du périmètre

  Scénario: Le formulaire accepte les codes INSEE Corse et à zéro de tête
    Sachant que je suis un demandeur
    Et que l’API géo connaît la commune "2A004" nommée "Ajaccio"
    Et que l’API géo connaît la commune "01001" nommée "L’Abergement-Clémenciat"
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
