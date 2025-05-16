# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Particulier (en une seule étape)
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Plan du scénario: Je soumets une demande d'habilitation d'un éditeur avec le contact technique déjà renseigné pour un cas d'usage lié au portail famille ou à la tarification QF
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter ma demande"

    * je renseigne les informations du délégué à la protection des données
    * je renseigne les informations du contact métier
    * je remplis "URL de la délibération tarifaire" avec "https://mairie.fr/deliberation-tarifaire.pdf"
    * je renseigne les infos concernant les données personnelles

    * j'enregistre et continue vers le résumé

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire | Nom de l'éditeur                      |
      | Pandore           | Odyssée Informatique                  |
      | eTicket           | Qiis                                  |
      | Maelis Portail    | SIGEC                                 |

  Plan du scénario: Je soumets une demande d'habilitation d'un éditeur avec le contact technique non renseigné pour un cas d'usage lié au portail famille ou à la tarification QF
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter ma demande"

    * je remplis "URL de la délibération tarifaire" avec "https://mairie.fr/deliberation-tarifaire.pdf"
    * je renseigne les infos concernant les données personnelles

    * je renseigne les informations du délégué à la protection des données
    * je renseigne les informations du contact technique
    * je renseigne les informations du contact métier

    * j'enregistre et continue vers le résumé

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire         | Nom de l'éditeur      |
      | FAST                      | DOCAPOSTE             |
      | Publik Famille            | Entr'ouvert           |
      | Axel                      | Teamnet               |

  Scénario: Je soumets une demande d'habilitation de l'éditeur AFI avec le contact technique déjà renseigné pour un cas d'usage lié au CCAS
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Mélissandre" de l'éditeur "Agence Française d'Informatique (AFI)"
    Et que je clique sur "Débuter ma demande"

    * je renseigne le cadre légal
    * je renseigne les infos concernant les données personnelles

    * je renseigne les informations du contact métier
    * je renseigne les informations du délégué à la protection des données

    * j'enregistre et continue vers le résumé

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"
