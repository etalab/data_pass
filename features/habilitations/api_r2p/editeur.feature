
# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API R2P éditeur
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Plan du scénario: Je soumets une demande d'habilitation valide
    Quand je veux remplir une demande pour "API R2P" via le formulaire "<Nom du formulaire>" à l'étape "Production"

    * je clique sur "Débuter ma demande"
    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je coche "Recherche par état civil dégradé et éléments d’adresse - Restitution de l’état civil complet, de l’adresse et du code postal"
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je renseigne les informations du contact technique
    * je clique sur "Suivant"

    * je renseigne la recette fonctionnelle
    * je clique sur "Suivant"

    * je renseigne l'homologation de sécurité
    * je clique sur "Suivant"

    * je renseigne la volumétrie
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire                                                                       |

      | Demande libre avec éditeur                                                              |
      | Ordonnateur avec éditeur                                                                |
      | Restitution du numéro fiscal (SPI) pour appel de l’API Impôt particulier avec éditeur   |
