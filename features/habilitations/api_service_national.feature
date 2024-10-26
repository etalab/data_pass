# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Service National

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Et je démarre une nouvelle demande d'habilitation "API Service National"

  Scénario: Je soumets une demande d'habilitation libre valide
    Quand je clique sur "Demande libre"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    * je remplis "Précisez la nature et les références du texte vous autorisant à traiter les données" avec "Article 42"
    * je remplis "URL du texte relatif au traitement" avec "https://legifrance.gouv.fr/affichCodeArticle.do?idArticle=LEGIARTI000006430983&cidTexte=LEGITEXT000006070721"
    * je clique sur "Suivant"

    * je renseigne les informations des contacts RGPD
    * je renseigne les informations du contact technique
    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation Inscription à un concours ou un examen (hors permis de conduire) valide
    Quand je clique sur "Inscription à un concours ou un examen (hors permis de conduire)"

    * je renseigne les infos de bases du projet
    * je renseigne les infos concernant les données personnelles
    * je renseigne les informations des contacts RGPD

    * je renseigne les informations du contact technique

    * j'enregistre et continue vers le résumé

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  Scénario: Je soumets une demande d'habilitation Accès à un statut exigeant d’être en règle avec les obligations de service national valide
    Quand je clique sur "Accès à un statut exigeant d’être en règle avec les obligations de service national"

    * je renseigne les infos de bases du projet
    * je renseigne les infos concernant les données personnelles
    * je renseigne les informations des contacts RGPD

    * je renseigne les informations du contact technique

    * j'enregistre et continue vers le résumé

    * j'adhère aux conditions générales
    * je clique sur "Soumettre la demande d'habilitation"

    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"
