# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Entreprise
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Et je démarre une nouvelle demande d'habilitation "API Entreprise"

  Scénario: Je soumets une demande d'habilitation libre valide
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Demande libre"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je coche "Données unités légales et établissements du répertoire Sirene - Insee (diffusibles et non-diffusibles)"
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je remplis les informations du contact "Contact métier" avec :
      | Nom    | Prénom  | Email                | Téléphone   | Fonction    |
      | Dupont | Louis   | dupont.louis@gouv.fr | 08366565602 | Métier      |
    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom  | Email               | Téléphone   | Fonction    |
      | Dupont | Marc    | dupont.marc@gouv.fr | 08366565603 | Technique   |
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Plan du scénario: Je soumets une demande d'habilitation pour un cas d'usage spécifique, dont le cadre légal est déjà rempli
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "<Cas d'usage>"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les infos de bases du projet
    * je remplis "Date de mise en production" avec "25/12/2042"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je clique sur "Suivant"

    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je remplis les informations du contact "Contact métier" avec :
      | Nom    | Prénom  | Email                | Téléphone   | Fonction    |
      | Dupont | Louis   | dupont.louis@gouv.fr | 08366565602 | Métier      |
    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom  | Email               | Téléphone   | Fonction    |
      | Dupont | Marc    | dupont.marc@gouv.fr | 08366565603 | Technique   |
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Cas d'usage                  |
      | Marchés publics              |
      | Portail GRU - Préremplissage |

  Plan du scénario: Je soumets une demande d'habilitation pour un cas d'usage spécifique, dont le cadre légal n'est pas rempli
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "<Cas d'usage>"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je renseigne le cadre légal
    * je clique sur "Suivant"

    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je remplis les informations du contact "Contact métier" avec :
      | Nom    | Prénom  | Email                | Téléphone   | Fonction    |
      | Dupont | Louis   | dupont.louis@gouv.fr | 08366565602 | Métier      |
    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom  | Email               | Téléphone   | Fonction    |
      | Dupont | Marc    | dupont.marc@gouv.fr | 08366565603 | Technique   |
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Cas d'usage                             |
      | Aides publiques                         |
      | Subventions des associations            |
      | Portail GRU - Instruction des démarches |
      | Détection de la fraude                  |

  Plan du scénario: Je soumets une demande d'habilitation d'un éditeur
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "<Nom du formulaire>" de l'éditeur "<Nom de l'éditeur>"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

    Exemples:
      | Nom du formulaire                     | Nom de l'éditeur  |
      | Conformité titulaires de marchés      | e-Attestations    |
      | Conformité titulaires de marchés      | Provigis          |
      | Conformité titulaires de marchés      | Achat Solution    |
      | Dématérialisation des marchés publics | Atexo             |
      | Dématérialisation des marchés publics | SETEC             |
      | Solution Portail des aides            | MGDIS             |
