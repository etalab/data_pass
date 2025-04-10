# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API le.Taxi
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Plan du scénario: Je soumets une demande d'habilitation valide
    Quand je veux remplir une demande pour "API le.Taxi" via le formulaire "<Nom du formulaire>"
    Et que je clique sur "Débuter ma demande"

    * je sélectionne "Mon équipe de développeur" pour "Qui s'occupe des aspects techniques et informatiques"
    * je clique sur "Suivant"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je renseigne les informations du contact technique
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire                         |
      | Demande libre                             |
      | Applicatif chauffeur                      |
      | Applicatif client                         |
      | Applicatif chauffeur et applicatif client |
