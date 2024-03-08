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
    * je remplis "Date de mise en production" avec "25/12/2042"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je remplis "Précisez la nature et les références du texte vous autorisant à traiter les données" avec "Article 42"
    * je remplis "URL du texte relatif au traitement" avec "https://legifrance.gouv.fr/affichCodeArticle.do?idArticle=LEGIARTI000006430983&cidTexte=LEGITEXT000006070721"
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

  Scénario: Je soumets une demande d'habilitation pour le cas d'usage des Marchés publics
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Marchés publics"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les infos de bases du projet
    * je remplis "Date de mise en production" avec "25/12/2042"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
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

  Scénario: Je soumets une demande d'habilitation pour le cas d'usage des Aides publiques
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Aides publiques"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les infos de bases du projet
    * je remplis "Date de mise en production" avec "25/12/2042"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je remplis "Précisez la nature et les références du texte vous autorisant à traiter les données" avec "Article 42"
    * je remplis "URL du texte relatif au traitement" avec "https://legifrance.gouv.fr/affichCodeArticle.do?idArticle=LEGIARTI000006430983&cidTexte=LEGITEXT000006070721"
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

  Scénario: Je soumets une demande d'habilitation pour le cas d'usage des subventions des associations
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Subventions des associations"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les infos de bases du projet
    * je remplis "Date de mise en production" avec "25/12/2042"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je remplis "Précisez la nature et les références du texte vous autorisant à traiter les données" avec "Article 42"
    * je remplis "URL du texte relatif au traitement" avec "https://legifrance.gouv.fr/affichCodeArticle.do?idArticle=LEGIARTI000006430983&cidTexte=LEGITEXT000006070721"
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

  Scénario: Je soumets une demande d'habilitation pour le cas d'usage GRU en préremplissage
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Portail GRU - Préremplissage"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les infos de bases du projet
    * je remplis "Date de mise en production" avec "25/12/2042"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
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

  Scénario: Je soumets une demande d'habilitation pour le cas d'usage GRU instruction
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Portail GRU - Instruction des démarches"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les infos de bases du projet
    * je remplis "Date de mise en production" avec "25/12/2042"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
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

  Scénario: Je soumets une demande d'habilitation détection de la fraude
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Détection de la fraude"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les infos de bases du projet
    * je remplis "Date de mise en production" avec "25/12/2042"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je remplis "Précisez la nature et les références du texte vous autorisant à traiter les données" avec "Article 42"
    * je remplis "URL du texte relatif au traitement" avec "https://legifrance.gouv.fr/affichCodeArticle.do?idArticle=LEGIARTI000006430983&cidTexte=LEGITEXT000006070721"
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

  Scénario: Je soumets une demande d'habilitation e-Attestations
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Conformité titulaires de marchés" de l'éditeur "e-Attestations"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation Provigis
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Conformité titulaires de marchés" de l'éditeur "Provigis"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation Achat solution
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Conformité titulaires de marchés" de l'éditeur "Achat Solution"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation Atexo
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Dématérialisation des marchés publics" de l'éditeur "Atexo"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation Setec-Atexos
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Dématérialisation des marchés publics" de l'éditeur "SETEC"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation MGDIS valide
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Solution Portail des aides" de l'éditeur "MGDIS"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"
