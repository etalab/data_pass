# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Particulier (en plusiuers étapes)
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je soumets une demande d'habilitation libre valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Demande libre"
    Et que je clique sur "Débuter ma demande"
    Et la page ne contient pas "Nous avons pré-rempli des informations pour vous aider"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je clique sur "Suivant"

    * je coche "Quotient familial CAF & MSA"
    * je clique sur "Suivant"

    * je renseigne les informations du délégué à la protection des données
    * je renseigne les informations du contact technique
    * je renseigne les informations du contact métier

    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Plan du scénario: Je soumets une demande d'habilitation pour un cas d'usage sans éditeur où je dois préciser le cadre légal et le lien vers la délibération
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>"
    Et que je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je remplis "Description du cadre juridique autorisant à traiter les données*" avec "Article 42"
    * je remplis "Indiquez une URL vers la délibération" avec "https://legifrance.gouv.fr/affichCodeArticle.do?idArticle=LEGIARTI000006430983&cidTexte=LEGITEXT000006070721"
    * je clique sur "Suivant"

    * je coche "Quotient familial CAF & MSA"
    * je clique sur "Suivant"

    * je renseigne les informations du délégué à la protection des données
    * je renseigne les informations du contact technique
    * je renseigne les informations du contact métier

    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire                                        |
      | Tarification sociale des services municipaux à l’enfance |
      | Aides facultatives régionales                            |
      | Aides facultatives départementales                       |
      | Tarification cantine collèges                            |
      | Aides sociales des CCAS dont aides facultatives          |
      | Tarification des transports                              |

  Scénario: Je soumets une demande d'habilitation pour le cas d'usage "Tarification cantine lycées"
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Tarification cantine lycées"
    Et que je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je remplis "Précisez la nature et les références du texte vous autorisant à traiter les données" avec "Article 42"
    * je remplis "URL du texte relatif au traitement" avec "https://legifrance.gouv.fr/affichCodeArticle.do?idArticle=LEGIARTI000006430983&cidTexte=LEGITEXT000006070721"
    * je clique sur "Suivant"

    * je coche "Quotient familial CAF & MSA"
    * je clique sur "Suivant"

    * je renseigne les informations du délégué à la protection des données
    * je renseigne les informations du contact technique
    * je renseigne les informations du contact métier

    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"


  Scénario: Je soumets une demande d'habilitation pour le cas d'usage "Aides sociales des CCAS"
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Aides sociales des CCAS"
    Et que je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je coche "Quotient familial CAF & MSA"
    * je clique sur "Suivant"

    * je renseigne les informations du délégué à la protection des données
    * je renseigne les informations du contact métier
    * je renseigne les informations du contact technique

    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation pour le cas d'usage "Gestion RH du secteur public"
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Gestion RH du secteur public"
    Et que je clique sur "Débuter ma demande"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je remplis "Description du cadre juridique autorisant à traiter les données*" avec "Article 42"
    * je remplis "URL du texte relatif au traitement" avec "https://legifrance.gouv.fr/affichCodeArticle.do?idArticle=LEGIARTI000006430983&cidTexte=LEGITEXT000006070721"
    * je clique sur "Suivant"

    * "Identité de l'étudiant" est coché
    * je clique sur "Suivant"

    * je renseigne les informations du délégué à la protection des données
    * je renseigne les informations du contact technique
    * je renseigne les informations du contact métier

    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Plan du scénario: Je soumets une demande d'habilitation d'un éditeur avec le contact technique déjà renseigné et des scopes modifiables pour un cas d'usage lié au portail famille ou à la tarification QF
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter ma demande"

    Et la page contient "Nous avons pré-rempli des informations pour vous aider"

    * je clique sur "Suivant"

    * je remplis "URL de la délibération tarifaire" avec "https://mairie.fr/deliberation-tarifaire.pdf"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne les informations du délégué à la protection des données
    * je renseigne les informations du contact métier
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
      | FamilyClic          | JCDeveloppement           |
      | Carte Plus          | Carte Plus                |
      | YGRC                | Ypok                      |

   Plan du scénario: Je soumets une demande d'habilitation d'un éditeur avec le contact technique non renseigné et des scopes non modifiables pour un cas d'usage lié au portail famille ou à la tarification QF
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter ma demande"

    * je clique sur "Suivant"

    * je remplis "URL de la délibération tarifaire" avec "https://mairie.fr/deliberation-tarifaire.pdf"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne les informations du délégué à la protection des données
    * je renseigne les informations du contact technique
    * je renseigne les informations du contact métier

    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire         | Nom de l'éditeur  |
      | Concerto                  | Arpège            |
      | Civil Enfance             | Ciril GROUP       |
      | ILE - Kiosque famille     | Technocarte       |
      | Loyfeey                   | Ecorestauration   |
      | Kosmos Education          | Kosmos            |
      | AchetezA                  | AchetezA           |

   Plan du scénario: Je soumets une demande d'habilitation d'un éditeur avec le contact technique non renseigné et des scopes modifiables pour un cas d'usage lié au portail famille ou à la tarification QF
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter ma demande"

    * je clique sur "Suivant"

    * je remplis "URL de la délibération tarifaire" avec "https://mairie.fr/deliberation-tarifaire.pdf"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne les informations du délégué à la protection des données
    * je renseigne les informations du contact technique
    * je renseigne les informations du contact métier

    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire         | Nom de l'éditeur  |
      | Noethys                   | Noethys           |
      | Res'Agenda                | Res'Agenda        |

  Plan du scénario: Je soumets une demande d'habilitation d'un éditeur avec le contact technique non renseigné et des scopes non modifiables pour un cas d'usage lié au CCAS, où le cadre juridique est déjà renseigné
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter ma demande"

    * je clique sur "Suivant"

    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne les informations du délégué à la protection des données
    * je renseigne les informations du contact technique
    * je renseigne les informations du contact métier

    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire         | Nom de l'éditeur  |
      | Sonate                    | Arpège            |
      | Millésime Action Sociale  | Arche MC2         |

  Plan du scénario: Je soumets une demande d'habilitation d'un éditeur avec le contact technique renseigné et des scopes non modifiables pour un cas d'usage lié au CCAS, où le cadre juridique est déjà renseigné
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter ma demande"

    * je clique sur "Suivant"

    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne les informations du délégué à la protection des données
    * je renseigne les informations du contact métier

    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire         | Nom de l'éditeur  |
      | Paxtel                    | Paxtel            |

  Plan du scénario: Je soumets une demande d'habilitation d'un éditeur avec le contact technique renseigné et des scopes non modifiables pour un cas d'usage lié au portail famille ou à la tarification QF
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter ma demande"

    * je remplis "URL de la délibération tarifaire" avec "https://mairie.fr/deliberation-tarifaire.pdf"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne les informations du délégué à la protection des données
    * je renseigne les informations du contact métier
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire     | Nom de l'éditeur          |
      | Agora Plus            | Agora Plus                |
      | Cantine de France     | JDéalise                  |
      | Malice                | Amiciel                   |
      | Logiciel Enfance      | 3D Ouest                  |
      | MyPérischool          | Waigeo                    |
      | Fluo                  | Cosoluce                  |
      | iNoé                  | Aiga                      |
      | CapDemat Evolution    | CapDemat                  |
      | PourMesDossiers       | Esabora                   |
      | BL Enfance            | Berger-Levrault           |
      | Mairistem             | JVS-Mairistem             |
      | Epéris                | E1OS                      |

 Plan du scénario: Je soumets une demande d'habilitation d'un éditeur avec le contact technique déjà renseigné, sans cas d'usage
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter ma demande"

    * je remplis "Précisez la nature et les références du texte vous autorisant à traiter les données" avec "Article 42"
    * je remplis "URL de la délibération tarifaire" avec "https://mairie.fr/deliberation-tarifaire.pdf"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne les informations du délégué à la protection des données
    * je renseigne les informations du contact technique
    * je renseigne les informations du contact métier
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire     | Nom de l'éditeur          |
      | Ganesh Education      | Ganesh Education          |
      | DuoNET                | Ars Data                  |


Plan du scénario: Je soumets une demande d'habilitation d'un éditeur dont le contact technique n'est pas renseigné et des scopes non modifiables pour un cas d'usage lié à la tarification des transports
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter ma demande"

    Et la page contient "Nous avons pré-rempli des informations pour vous aider"

    * je clique sur "Suivant"

    * je remplis "URL de la délibération tarifaire" avec "https://mairie.fr/deliberation-tarifaire.pdf"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne les informations du délégué à la protection des données
    * je renseigne les informations du contact métier
    * je renseigne les informations du contact technique

    * je clique sur "Suivant"
    Et j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire   | Nom de l'éditeur          |
      | MaaSify             | Monkey Factory            |

  Plan du scénario: Je soumets une demande d'habilitation d'un éditeur avec le contact technique déjà renseigné et des scopes modifiables pour un cas d'usage lié à la tarification des transports
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter ma demande"

    Et la page contient "Nous avons pré-rempli des informations pour vous aider"

    * je clique sur "Suivant"

    * je remplis "URL de la délibération tarifaire" avec "https://mairie.fr/deliberation-tarifaire.pdf"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne les informations du délégué à la protection des données
    * je renseigne les informations du contact métier
    * je renseigne les informations du contact technique

    * je clique sur "Suivant"
    Et j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire   | Nom de l'éditeur          |
      | Airweb              | Airweb                    |
      | ICAR                | Coexya                    |

  Plan du scénario: Je soumets une demande d'habilitation d'un éditeur avec le contact technique déjà renseigné et des scopes modifiables pour un cas d'usage lié aux aides facultatives régionales ou aux aides facultatives départementales
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter ma demande"

    Et la page contient "Nous avons pré-rempli des informations pour vous aider"

    * je clique sur "Suivant"

    * je remplis "URL de la délibération tarifaire" avec "https://region.fr/deliberation-tarifaire.pdf"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne les informations du délégué à la protection des données
    * je renseigne les informations du contact métier
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"
    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire   | Nom de l'éditeur          |
      | Memberz             | Dialog                    |
