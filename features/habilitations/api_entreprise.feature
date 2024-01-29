# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Entreprise
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Et je démarre une nouvelle demande d'habilitation "API Entreprise"

  @javascript
  Scénario: Je soumets une demande d'habilitation libre valide
    Quand je choisis "Vos développeurs"
    Et que je clique sur "Demande libre"

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
    Et je suis sur la page "Accueil"

  @javascript
  Scénario: Je soumets une demande d'habilitation MGDIS valide
    Quand je choisis "Votre éditeur"
    Et que je choisis "MGDIS"
    Et que je clique sur "Solution Portail des aides de l'éditeur MGDIS"

    * je renseigne les informations des contacts RGPD
    * j'adhère aux conditions générales

    * je clique sur "Enregistrer les modifications"
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Accueil"
