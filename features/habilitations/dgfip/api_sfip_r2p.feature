# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Courtier fonctionnel SFiP R2P
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Plan du scénario: Je soumets une demande d'habilitation éditeur
    Quand je veux remplir une demande pour "API Courtier fonctionnel SFiP R2P" via le formulaire "<Nom du formulaire>"
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

    * j'adhère aux conditions générales

    * je coche "J’atteste que mon organisation devra déclarer à la DGFiP l’accomplissement des formalités en matière de protection des données à caractère personnel et qu’elle veillera à procéder à l’homologation de sécurité de son projet."

    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire                                                                       |

      | Demande libre (Bac à sable)                                                             |
      | Demande Ordonnateur (Bac à sable)                                                       |
      | Restitution du numéro fiscal (SPI) pour appel de l’API Impôt particulier (Bac à sable)  |

  Plan du scénario: Je soumets une demande d'habilitation de bac à sable valide
    Quand je veux remplir une demande pour "API Courtier fonctionnel SFiP R2P" via le formulaire "<Nom du formulaire>" à l'étape "Bac à sable"

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

    * j'adhère aux conditions générales

    * je coche "J’atteste que mon organisation devra déclarer à la DGFiP l’accomplissement des formalités en matière de protection des données à caractère personnel et qu’elle veillera à procéder à l’homologation de sécurité de son projet."

    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire                                                                       |

      | Demande libre (Bac à sable)                                                             |
      | Demande Ordonnateur (Bac à sable)                                                       |
      | Restitution du numéro fiscal (SPI) pour appel de l’API Impôt particulier (Bac à sable)  |

  Plan du scénario: Je soumets une demande d'habilitation de production valide
    Quand j'ai 1 demande d'habilitation "API Courtier fonctionnel SFiP R2P" via le formulaire "<Nom du formulaire>" à l'étape "Bac à sable" validée
    Et que je me rends sur mon tableau de bord demandeur habilitations
    Et que je clique sur "Démarrer ma demande d’habilitation en production"
    Et que je clique sur "Débuter ma demande"

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

      | Demande libre (Bac à sable)                                                             |
      | Demande Ordonnateur (Bac à sable)                                                       |
      | Restitution du numéro fiscal (SPI) pour appel de l’API Impôt particulier (Bac à sable)  |
