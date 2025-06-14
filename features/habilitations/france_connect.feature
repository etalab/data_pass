# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation FranceConnect
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Plan du scénario: Je soumets une demande d'habilitation valide
    Quand je veux remplir une demande pour "FranceConnect" via le formulaire "<Nom du formulaire>"
    Et que je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je renseigne la catégorie FranceConnect Eidas
    * je clique sur "Suivant"

    * je coche "Nom de naissance"
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je renseigne les informations du contact technique
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je coche "J’atteste que mon service propose une alternative à la connexion avec FranceConnect, et que cette alternative permet l’accès, dans des conditions analogues, à la même prestation de service public."
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire                                        |
      | Demande libre                                            |
      | Demande de collectivité / administration                 |
      | Demande de collectivité - e-permis                       |
      | Demande d'un service numérique en santé                  |
