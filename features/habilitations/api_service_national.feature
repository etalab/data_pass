# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Service National

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Et je démarre une nouvelle demande d'habilitation "API Service National"
    Et que je clique sur "Démarrer"

  Scénario: Je soumets une demande d'habilitation libre valide
    Quand je clique sur "Démarrer" pour le formulaire "Demande libre"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je remplis "Précisez la nature et les références du texte vous autorisant à traiter les données" avec "Article 42"
    * je remplis "URL du texte relatif au traitement" avec "https://legifrance.gouv.fr/affichCodeArticle.do?idArticle=LEGIARTI000006430983&cidTexte=LEGITEXT000006070721"
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom | Email               | Téléphone   | Fonction  |
      | Dupont | Marc   | dupont.marc@gouv.fr | 08366565603 | Technique |
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Accueil"

  Scénario: Je soumets une demande d'habilitation Inscription à un concours ou un examen (hors permis de conduire) valide
    Quand je clique sur "Démarrer" pour le formulaire "Inscription à un concours ou un examen (hors permis de conduire)"

    * je renseigne les infos de bases du projet
    * je renseigne les infos concernant les données personnelles
    * je renseigne les informations des contacts RGPD

    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom | Email               | Téléphone   | Fonction  |
      | Dupont | Marc   | dupont.marc@gouv.fr | 08366565603 | Technique |
    * j'adhère aux conditions générales

    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Accueil"

  Scénario: Je soumets une demande d'habilitation Accès à un statut exigeant d’être en règle avec les obligations de service national valide
    Quand je clique sur "Démarrer" pour le formulaire "Accès à un statut exigeant d’être en règle avec les obligations de service national"

    * je renseigne les infos de bases du projet
    * je renseigne les infos concernant les données personnelles
    * je renseigne les informations des contacts RGPD

    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom | Email               | Téléphone   | Fonction  |
      | Dupont | Marc   | dupont.marc@gouv.fr | 08366565603 | Technique |
    * j'adhère aux conditions générales

    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Accueil"
