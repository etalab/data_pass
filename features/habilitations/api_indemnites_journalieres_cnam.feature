# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Indemnités Journalières de la CNAM
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je ne peux pas démarrer de demande si je n'ai pas d'habilitation FranceConnect
    Quand je veux remplir une demande pour "API Indemnités Journalières de la CNAM"
    Alors la page contient "Vous ne possédez pas d'habilitation à FranceConnect"
    Et la page ne contient pas "Demande libre"

  Scénario: Je soumets une demande d'habilitation valide
    Sachant que mon organisation a 1 demande d'habilitation "FranceConnect" validée
    Et je veux remplir une demande pour "API Indemnités Journalières de la CNAM"
    * je clique sur "Demande libre"
    * je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je sélectionne la première option pour "FranceConnect"
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je renseigne les informations du contact technique
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"
