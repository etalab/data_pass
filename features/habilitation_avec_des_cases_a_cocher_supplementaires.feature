# language: fr

Fonctionnalité: Habilitation avec des cases à cocher supplémentaires
  Une demande d'habilitation peut posséder des cases à cocher supplémentaires
  à l'étape résumé, celles-ci sont obligatoires.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

    Et que je veux remplir une demande pour "FranceConnect" via le formulaire "Demande libre"
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
    * je renseigne les informations du contact technique avec un numéro de mobile
    * je clique sur "Suivant"


  Scénario: Je coche toutes les cases
    Quand j'adhère aux conditions générales
    Et que je coche "J’atteste que mon service propose une alternative à la connexion avec FranceConnect, et que cette alternative permet l’accès, dans des conditions analogues, à la même prestation de service public."
    Et que je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je ne coche aucune case
    Quand je clique sur "Soumettre la demande d'habilitation"
    Alors il y a un message d'erreur contenant "Vous devez acceptez les conditions générales avant de continuer"

  Scénario: Je ne coche pas les cases à cocher supplémentaire exclusivement
    Quand j'adhère aux conditions générales
    Et que je clique sur "Soumettre la demande d'habilitation"
    Alors il y a un message d'erreur contenant "Vous devez acceptez les conditions générales avant de continuer"
