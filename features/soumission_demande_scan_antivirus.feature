# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Entreprise
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Et je démarre une nouvelle demande d'habilitation "API Entreprise"

  @FlushJobQueue
  Scénario: Je soumets une demande d'habilitation libre valide
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Demande libre"
    Et que je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * Je joins une maquette au projet "API Entreprise"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je coche "Données unités légales et établissements du répertoire Sirene - Insee (diffusibles et non-diffusibles)"
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je renseigne les informations du contact métier
    * je renseigne les informations du contact technique
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors un scan antivirus est lancé
    Et il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"
