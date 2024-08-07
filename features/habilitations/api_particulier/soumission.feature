# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Particulier
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je soumets une demande d'habilitation libre valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Demande libre"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je coche "Quotient familial CAF & MSA"
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom  | Email               | Téléphone   | Fonction    |
      | Dupont | Marc    | dupont.marc@gouv.fr | 08366565603 | Technique   |
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Plan du scénario: Je soumets une demande d'habilitation, en plusieurs étapes, d'un éditeur avec le contact technique déjà renseigné et des scopes modifiables pour un cas d'usage lié au portail famille ou à la tarification QF
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter mon habilitation"

    * je clique sur "Suivant"

    * je remplis "URL de la délibération tarifaire" avec "https://mairie.fr/deliberation-tarifaire.pdf"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire   | Nom de l'éditeur          |
      | Domino web 2.0      | Abelium Collectivités     |
      | City Family         | Mushroom Software         |
      | NFI                 | Nord France Informatique  |
      | Proxima.ENF         | AGEDI                     |

  Plan du scénario: Je soumets une demande d'habilitation, en plusieurs étapes, d'un éditeur avec le contact technique non renseigné et des scopes non modifiables pour un cas d'usage lié au portail famille ou à la tarification QF
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter mon habilitation"

    * je clique sur "Suivant"

    * je remplis "URL de la délibération tarifaire" avec "https://mairie.fr/deliberation-tarifaire.pdf"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom  | Email               | Téléphone   | Fonction    |
      | Dupont | Marc    | dupont.marc@gouv.fr | 08366565603 | Technique   |
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire         | Nom de l'éditeur  |
      | Concerto opus             | Arpège            |
      | Civil Enfance             | Ciril GROUP       |
      | ILE - Kiosque famille     | Technocarte       |
      | Loyfeey                   | Ecorestauration   |

  Plan du scénario: Je soumets une demande d'habilitation, en plusieurs étapes, d'un éditeur avec le contact technique non renseigné et des scopes non modifiables pour un cas d'usage lié au CCAS
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter mon habilitation"

    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom  | Email               | Téléphone   | Fonction    |
      | Dupont | Marc    | dupont.marc@gouv.fr | 08366565603 | Technique   |
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire         | Nom de l'éditeur  |
      | Sonate                    | Arpège            |
      | Millésime Action Sociale  | Arche MC2         |

  Plan du scénario: Je soumets une demande d'habilitation, en plusieurs étapes, d'un éditeur avec le contact technique renseigné et des scopes non modifiables pour un cas d'usage lié au portail famille ou à la tarification QF
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter mon habilitation"

    * je remplis "URL de la délibération tarifaire" avec "https://mairie.fr/deliberation-tarifaire.pdf"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire     | Nom de l'éditeur          |
      | Agora Plus            | Agora Plus                |
      | Cantines de France    | JDéalise                  |
      | Malice                | Amiciel                   |
      | Logiciel Enfance      | 3D Ouest                  |
      | MyPérischool          | Waigeo                    |
      | Fluo                  | Cosoluce                  |


  Plan du scénario: Je soumets une demande d'habilitation, présenté en une seule page, d'un éditeur avec le contact technique déjà renseigné pour un cas d'usage lié au portail famille ou à la tarification QF
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL de la délibération tarifaire" avec "https://mairie.fr/deliberation-tarifaire.pdf"
    * je renseigne les infos concernant les données personnelles

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire | Nom de l'éditeur                      |
      | iNoé              | Aiga                                  |
      | ICAR              | Coexya                                |
      | BL Enfance        | Berger-Levrault                       |
      | Pandore           | Odyssée Informatique                  |
      | eTicket           | Qiis                                  |
      | Maelis Portail    | SIGEC                                 |

  Plan du scénario: Je soumets une demande d'habilitation, présenté en une seule page, d'un éditeur avec le contact technique non renseigné pour un cas d'usage lié au portail famille ou à la tarification QF
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL de la délibération tarifaire" avec "https://mairie.fr/deliberation-tarifaire.pdf"
    * je renseigne les infos concernant les données personnelles

    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom  | Email               | Téléphone   | Fonction    |
      | Dupont | Marc    | dupont.marc@gouv.fr | 08366565603 | Technique   |

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire         | Nom de l'éditeur      |
      | FAST                      | DOCAPOSTE             |
      | Publik Famille            | Entrouvert            |
      | Parascol                  | JVS-Mairistem         |
      | Axel                      | Teamnet               |

  Scénario: Je soumets une demande d'habilitation, présenté en une seule page, de l'éditeur AFI avec le contact technique déjà renseigné pour un cas d'usage lié au CCAS
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Mélissandre" de l'éditeur "Agence Française d'Informatique (AFI)"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je renseigne le cadre légal
    * je renseigne les infos concernant les données personnelles

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"
