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

  Plan du scénario: Je soumets une demande d'habilitation d'un éditeur avec le contact technique déjà renseigné
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
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

    Exemples:
      | Nom du formulaire                                                         | Nom de l'éditeur                      |
      | iNoé, Tarification services municipaux / Portail Famille                  | Aiga                                  |
      | Coexya, solution portail tarification sociale et solidaire ICAR           | Coexya                                |
      | Agora Famille Premium, Tarification services municipaux / Portail Famille | Agora Plus                            |
      | BL Enfance, Tarification services municipaux / Portail Famille            | Berger-Levrault                       |
      | Cantines-de-France, Tarification services municipaux / Portail Famille    | Jdéalise (Cantine de France)          |
      | Mélissandre, Dématérialisation de l'instruction des dossiers dans un CCAS | Agence Française d'Informatique (AFI) |
      | City Family, Tarification services municipaux / Portail Famille           | Mushroom Software                     |
      | Civil Enfance, Tarification services municipaux / Portail Famille         | Ciril GROUP                           |
      | Fluo, Tarification services municipaux / Portail Famille                  | Cosoluce                              |
      | Tarification services municipaux / Portail Famille                        | Nord France Informatique              |
      | Pandore, Tarification services municipaux / Portail Famille               | Odyssée Informatique                  |
      | eTicket, Tarification services municipaux / Portail Famille               | Qiis                                  |
      | Maelis Portail, Tarification services municipaux / Portail Famille        | SIGEC                                 |
      | ILE, Tarification service enfance                                         | Technocarte                           |
      | MyPerischool, Tarification services municipaux / Portail Famille          | Waigeo                                |
      | 3D Ouest, Tarification services municipaux / Portail Famille              | 3D Ouest                              |

  Plan du scénario: Je soumets une demande d'habilitation d'un éditeur avec le contact technique non renseigné
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je renseigne le cadre légal
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
      | Nom du formulaire                                                             | Nom de l'éditeur      |
      | Domino web 2.0, Tarification services municipaux / Portail Famille            | Abelium Collectivités |
      | Malice, Tarification services municipaux / Portail Famille                    | Amiciel               |
      | Concerto, Tarification services municipaux / Portail Famille                  | Arpège                |
      | Arche MC2, Dématérialisation de l'instruction des dossiers dans un CCAS/CIAS  | Arche MC2             |
      | Dématérialisation de l'instruction des dossiers dans un CCAS                  | Arpège                |
      | Tarification services municipaux / Portail Famille                            | DOCAPOSTE             |
      | Publik Famille, Tarification services municipaux / Portail Famille            | Entrouvert            |
      | Parascol, Tarification services municipaux / Portail Famille                  | JVS-Mairistem         |
      | Axel, Tarification services municipaux / Portail Famille                      | Teamnet               |
