# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation API Particulier qui n'est que FranceConnectée
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Et que je veux remplir une demande pour "API Particulier" via le formulaire "Gestion du stationnement résidentiel"

  Scénario: Je ne peux pas démarrer de demande si je n'ai pas d'habilitation FranceConnect
    Quand je clique sur "Débuter ma demande"
    Alors la page contient "Demander une habilitation FranceConnect"
    Et je clique sur "Suivant"
    Alors il y a un message d'erreur contenant "L'habilitation FranceConnect doit être rempli(e)"

  Scénario: Je peux soumettre une demande si j'ai une habilitation FranceConnect
    Sachant que mon organisation a 1 demande d'habilitation "FranceConnect" validée
    Quand je clique sur "Débuter ma demande"
    * je clique sur "Suivant"

    * je renseigne les infos de bases du projet
    * je clique sur "Suivant"

    * je renseigne les infos concernant les données personnelles
    * je clique sur "Suivant"

    # Cadre légal
    * je remplis "Description du cadre juridique autorisant à traiter les données*" avec "Article 42"
    * je remplis "Indiquez une URL vers la délibération" avec "https://legifrance.gouv.fr/affichCodeArticle.do?idArticle=LEGIARTI000006430983&cidTexte=LEGITEXT000006070721"
    * je clique sur "Suivant"

    # Données demandées
    * je clique sur "Suivant"

    * je renseigne les informations du délégué à la protection des données
    * je renseigne les informations du contact technique
    * je renseigne les informations du contact métier

    * je clique sur "Suivant"

    * j'adhère aux conditions générales
    * je clique sur "Soumettre"
    Alors il y a un message de succès contenant "soumise avec succès"
