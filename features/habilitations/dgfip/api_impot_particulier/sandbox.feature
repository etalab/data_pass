# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Impôt Particulier - Bac à sable
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Plan du scénario: Je soumets une demande d'habilitation valide
    Quand je veux remplir une demande pour "API Impôt Particulier" via le formulaire "<Nom du formulaire>" à l'étape "Bac à sable"

    * je clique sur "Débuter ma demande"
    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je choisis "Via le numéro fiscal (SPI)"
    * je clique sur "Suivant"
    
    * je coche "Dernière année de revenu"
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je renseigne les informations du contact technique
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire                                        |

      | Demande libre (Bac à sable)                              |
      | Stationnement résidentiel (Bac à sable)                  |
      | Place en crèche (Bac à sable)                            |
      | Activités périscolaires (Bac à sable)                    |
      | Cantine scolaire (Bac à sable)                           |
      | Aides sociales facultatives (Bac à sable)                |
      | Carte de transport (Bac à sable)                         |
