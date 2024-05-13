# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Particulier
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je soumets une demande d'habilitation libre valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "Demande libre"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les infos de bases du projet
    * je remplis "Date de mise en production" avec "25/12/2042"
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je remplis "Précisez la nature et les références du texte vous autorisant à traiter les données" avec "Article 42"
    * je remplis "URL du texte relatif au traitement" avec "https://legifrance.gouv.fr/affichCodeArticle.do?idArticle=LEGIARTI000006430983&cidTexte=LEGITEXT000006070721"
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

  Scénario: Je soumets une demande d'habilitation Aiga valide
    Quand je veux remplir une demande pour "API Particulier" via le formulaire "iNoé, Tarification services municipaux / Portail Famille, Données CNAF" de l'éditeur "Aiga"
    Et que je clique sur "Débuter mon habilitation"

    * je renseigne les informations des contacts RGPD
    * je remplis "URL du texte relatif au traitement" avec "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000045213315"

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Continuer vers le résumé"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"
