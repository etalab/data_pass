# language: fr

Fonctionnalité: Registre wallet, étape « L’organisation »
  Le demandeur retrouve l’identité de son organisation, copiée dans sa demande depuis l’INSEE, et complète
  ce que le registre publie (DPP-207).

  Scénario: Une commune est un organisme du secteur public, son agent est connecté (CA1)
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Alors la page contient "Quelle organisation enregistrez-vous ?"
    Et la page contient "COMMUNE DE CLAMART"
    Et la page contient "Oui, d’après la catégorie juridique (Commune)"
    Et la page contient "1 place Maurice Gunsbourg, 92140 Clamart"
    Et la page ne contient pas "TVA intracommunautaire"
    Et la page contient "Agent connecté par ProConnect"
    Et la page contient "Étape 1/4"

  Scénario: Une SAS n’est pas un organisme du secteur public, sans badge (CA1)
    Sachant que je suis un demandeur d'une entreprise
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Alors la page contient "Non, d’après la catégorie juridique (SAS)"
    Et la page ne contient pas "Agent connecté par ProConnect"

  Scénario: Le dirigeant certifié le voit dans le bloc de l’organisation
    Sachant que je suis un demandeur d'une entreprise
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Alors la page contient "Certifié dirigeant par ProConnect"
    Et la page ne contient pas "Vérification de dirigeant à faire"

  Scénario: Une certification de dirigeant retirée est signalée dans le bloc, avec de quoi la refaire
    Sachant que je suis un demandeur d'une entreprise
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je clique sur "Enregistrer"
    Et ma certification de dirigeant est retirée
    Et je clique sur "Mettre à jour les informations de l’organisation"
    Alors la page contient "Quelle organisation enregistrez-vous ?"
    Et la page contient "Vérification de dirigeant à faire"
    Et la page ne contient pas "Certifié dirigeant par ProConnect"
    Quand je clique sur "Vérifier que je dirige l’organisation"
    Alors la page contient "Quelle organisation enregistrez-vous ?"
    Et la page contient "Certifié dirigeant par ProConnect"
    Et la page ne contient pas "Vérification de dirigeant à faire"

  Scénario: L’adresse d’un établissement non diffusible vient de Sirene et n’est pas publiée (CA2)
    Sachant que je suis un demandeur d'un établissement non diffusible dont Sirene donne l’adresse
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Alors la page contient "12 rue des Cyclistes, 69003 Lyon 3e Arrondissement"
    Et la page contient "ne sera pas publiée sur la fiche publique du registre"
    Et la page ne contient pas "Justificatif"
    Quand je remplis ce que le registre publie
    Et je coche "n’est enregistrée comme partie utilisatrice dans aucun autre État de l’Union"
    Et je clique sur "Suivant"
    Alors la page contient "Quel service demandera des données au wallet ?"
    Quand je décris le service "Vélocité Libre-service" avec l’identifiant "libre-service"
    Et je clique sur "Suivant"
    Et je remplis l’étape « Les utilisations prévues » du registre wallet
    Et je remplis l’étape « Les contacts » du registre wallet
    Alors la page contient "Vérifiez le récapitulatif de votre demande"
    Et la page contient "Non publiée : votre établissement n’est pas diffusible."

  Scénario: Sirene ne donne pas l’adresse d’un établissement non diffusible, le demandeur sait quoi faire (CA2)
    Sachant que je suis un demandeur d'un établissement non diffusible
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je clique sur "Enregistrer"
    Alors la page contient "L’adresse de votre établissement manque dans le répertoire Sirene"
    Et la page contient "mettez à jour les informations de votre établissement auprès de l’INSEE"
    Et la page contient "Relancer la récupération"
    Et la page ne contient pas "Adresse d’établissement"
    Et la page ne contient pas "Justificatif"

  Scénario: Rien n’a pu être récupéré, l’étape annonce qu’une récupération réussie sera nécessaire (CA3)
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Et que j’ai un brouillon du registre wallet dont l’identité n’a pas pu être récupérée
    Quand je reprends mon brouillon du registre wallet
    Alors la page contient "Le répertoire Sirene ne répond pas"
    Et la page contient "vous ne pourrez la soumettre qu’après une récupération réussie"
    Et la page contient "Numéro de SIRET (connexion ProConnect)"
    Et la page contient "Relancer la récupération"
    Et la page ne contient pas "Adresse d’établissement"
    Et la page ne contient pas "Justificatif"
    Quand je remplis ce que le registre publie
    Et je coche "n’est enregistrée comme partie utilisatrice dans aucun autre État de l’Union"
    Et je clique sur "Suivant"
    Alors la page ne contient pas "à corriger avant de continuer"
    Et la page contient "Quel service demandera des données au wallet ?"
    Quand je décris le service "Vélocité Libre-service" avec l’identifiant "libre-service"
    Et je clique sur "Suivant"
    Et je remplis l’étape « Les utilisations prévues » du registre wallet
    Alors la page contient "Vérifiez le récapitulatif de votre demande"

  Scénario: Les informations de l’organisation en cours de chargement s’affichent quand elles arrivent (R10)
    Sachant que je suis dirigeant d’une entreprise privée
    Et que le répertoire Sirene n’a pas encore renseigné mon organisation
    Et que je me connecte
    Quand je me rends sur la page de démarrage du registre wallet
    Et je clique sur "Débuter ma demande"
    Alors la page contient "Informations en cours de chargement"
    Et la page ne contient pas "Nom officiel de l’organisation"
    Quand je clique sur "Enregistrer"
    Et je remplis ce que le registre publie
    Et je coche "n’est enregistrée comme partie utilisatrice dans aucun autre État de l’Union"
    Et je clique sur "Suivant"
    Alors la page contient "Quel service demandera des données au wallet ?"
    Quand je décris le service "Vélocité Libre-service" avec l’identifiant "libre-service"
    Et je clique sur "Suivant"
    Et je remplis l’étape « Les utilisations prévues » du registre wallet
    Et je remplis l’étape « Les contacts » du registre wallet
    Alors la page ne contient pas "à corriger avant de continuer"
    Et la page contient "L’organisation dans le registre"
    Quand le répertoire Sirene renseigne mon organisation
    Et je reprends mon brouillon du registre wallet
    Alors la page contient "MGDIS"
    Et la page ne contient pas "Informations en cours de chargement"

  Scénario: Le demandeur relance le chargement des informations de l’organisation (R10)
    Sachant que je suis dirigeant d’une entreprise privée
    Et que le répertoire Sirene n’a pas encore renseigné mon organisation
    Et que je me connecte
    Quand je me rends sur la page de démarrage du registre wallet
    Et je clique sur "Débuter ma demande"
    Et je clique sur "Enregistrer"
    Et je clique sur "Mettre à jour les informations de l’organisation"
    Alors la page contient "Les informations de votre organisation sont à jour."
    Et la page contient "MGDIS"
    Et la page ne contient pas "Informations en cours de chargement"

  Scénario: Si le chargement échoue, le demandeur relance la récupération (R10, CA3)
    Sachant que je suis dirigeant d’une entreprise privée
    Et que le répertoire Sirene n’a pas encore renseigné mon organisation
    Et que je me connecte
    Quand je me rends sur la page de démarrage du registre wallet
    Et je clique sur "Débuter ma demande"
    Et je clique sur "Enregistrer"
    Et le répertoire Sirene ne répond plus
    Et je clique sur "Mettre à jour les informations de l’organisation"
    Alors la page contient "Le répertoire Sirene ne répond pas"
    Et la page contient "Relancer la récupération"
    Et la page ne contient pas "Nom officiel de l’organisation"
    Quand le répertoire Sirene répond de nouveau
    Et je clique sur "Relancer la récupération"
    Alors la page contient "MGDIS"
    Et la page ne contient pas "Le répertoire Sirene ne répond pas"

  Scénario: L’identité affichée est celle copiée dans la demande
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je clique sur "Enregistrer"
    Et l’INSEE renomme l’organisation en "VILLE DE CLAMART"
    Et je recharge la page
    Alors la page contient "COMMUNE DE CLAMART"
    Et la page ne contient pas "VILLE DE CLAMART"

  @javascript
  Scénario: Le demandeur met à jour l’identité préremplie sans quitter le bloc
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je clique sur "Enregistrer"
    Et la page contient "Brouillon enregistré à"
    Et l’INSEE renomme l’organisation en "VILLE DE CLAMART"
    Et je clique sur "Mettre à jour les informations de l’organisation"
    Alors la page contient "Les informations de votre organisation sont à jour."
    Et la page contient "VILLE DE CLAMART"

  Scénario: Sans politique de confidentialité ni assistance, le demandeur reste sur l’étape (CA4)
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je coche "n’est enregistrée comme partie utilisatrice dans aucun autre État de l’Union"
    Et je clique sur "Suivant"
    Alors la page contient "2 points à corriger avant de continuer"
    Et la page contient "Indiquez l’adresse de votre politique de confidentialité"
    Et la page contient "Assistance aux usagers : indiquez au moins un moyen."
    Et la page contient "Indiquez au moins un moyen d’assistance : un site, une adresse électronique ou un téléphone."
    Et la page contient "Quelle organisation enregistrez-vous ?"

  Scénario: Une adresse sans https:// et la case non cochée bloquent l’étape (CA5)
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je remplis ce que le registre publie
    Et je remplis "Site internet de l’organisation" avec "http://www.clamart.fr"
    Et je clique sur "Suivant"
    Alors la page contient "Site internet de l’organisation : l’adresse doit commencer par https://"
    Et la page contient "Cochez cette case pour continuer."

  @javascript
  Scénario: Le format d’une adresse est contrôlé dès que le demandeur quitte le champ (CA5)
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je remplis "Site internet de l’organisation" avec "http://www.clamart.fr"
    Et je quitte le champ "Site internet de l’organisation"
    Alors la page contient "Indiquez une adresse qui commence par https://"

  @javascript
  Scénario: Une adresse de la forme prénom.nom est signalée sans bloquer (RG4)
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je remplis "Adresse électronique" avec "camille.martin@clamart.fr"
    Et je quitte le champ "Adresse électronique"
    Alors la page contient "Cette adresse semble être celle d’une personne."

  Scénario: « Enregistrer » garde une étape incomplète sans message d’erreur (CA8)
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je remplis "Site internet de l’organisation" avec "https://www.clamart.fr"
    Et je clique sur "Enregistrer"
    Alors la page ne contient pas "à corriger avant de continuer"
    Et la page contient "Brouillon enregistré à"
    Et le champ "Site internet de l’organisation" contient "https://www.clamart.fr"

  @javascript
  Scénario: « Enregistrer » garde les valeurs bien formées et met de côté une valeur mal formée
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je clique sur "Enregistrer"
    Et la page contient "Brouillon enregistré à"
    Et je remplis "Adresse électronique" avec "contact@clamart.fr"
    Et je remplis "Site internet de l’organisation" avec "http://www.clamart.fr"
    Et je clique sur "Enregistrer"
    Alors il y a un message d'attention contenant "Brouillon enregistré, sauf une valeur au format invalide : Site internet de l’organisation"
    Et la page contient "Indiquez une adresse qui commence par https://"
    Et le champ "Site internet de l’organisation" contient "http://www.clamart.fr"
    Et le brouillon du registre wallet a pour site ""

  @javascript
  Scénario: Le brouillon s’enregistre quand le demandeur quitte un champ (CA8)
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je clique sur "Enregistrer"
    Et la page contient "Brouillon enregistré à"
    Et je remplis "Site internet de l’organisation" avec "https://www.clamart.fr", je quitte le champ et le brouillon s’enregistre
    Alors le brouillon du registre wallet a pour site "https://www.clamart.fr"

  Scénario: Supprimer le brouillon le archive et revient à l’introduction (CA9)
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je clique sur "Enregistrer"
    Et je clique sur "Supprimer"
    Alors la page contient "Suppression de la demande « Enregistrement d’une partie utilisatrice »"
    Et la page contient "Vérifiez que vous ne supprimez pas une demande que vous voulez garder."
    Et le brouillon du registre wallet n'est pas archivé
    Quand je clique sur "Supprimer la demande"
    Alors il y a un message de succès contenant "La demande « Enregistrement d’une partie utilisatrice » a été supprimée avec succès"
    Et la page contient "Avant de commencer, préparez"
    Et le brouillon du registre wallet est archivé

  Scénario: La demande ne peut pas encore être soumise
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je remplis ce que le registre publie
    Et je coche "n’est enregistrée comme partie utilisatrice dans aucun autre État de l’Union"
    Et je clique sur "Suivant"
    Et je décris le service "Vélocité Libre-service" avec l’identifiant "libre-service"
    Et je clique sur "Suivant"
    Et je remplis l’étape « Les utilisations prévues » du registre wallet
    Et je remplis l’étape « Les contacts » du registre wallet
    Alors la page contient "Les contacts de l’organisation"
    Et il n'y a pas de bouton "Soumettre la demande d'habilitation"

  Scénario: Le récapitulatif présente l’organisation dans le registre, sans le panneau de l’étape 1 (R4)
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je remplis ce que le registre publie
    Et je coche "n’est enregistrée comme partie utilisatrice dans aucun autre État de l’Union"
    Et je clique sur "Suivant"
    Et je décris le service "Vélocité Libre-service" avec l’identifiant "libre-service"
    Et je clique sur "Suivant"
    Et je remplis l’étape « Les utilisations prévues » du registre wallet
    Et je remplis l’étape « Les contacts » du registre wallet
    Alors la page contient "L’organisation dans le registre"
    Et la page contient "Identification"
    Et la page contient "Informations pour les usagers"
    Et la page contient "Politique de confidentialité par défaut"
    Et la page contient "Assistance aux usagers"
    Et la page contient "Non-inscription dans un autre État"
    Et la page contient "Déclarée"
    Et la page ne contient pas "Agent connecté par ProConnect"
    Et la page ne contient pas "Wallet privacy policy url"

  Scénario: Le récapitulatif annonce une vérification par le registre, pas une instruction
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je remplis ce que le registre publie
    Et je coche "n’est enregistrée comme partie utilisatrice dans aucun autre État de l’Union"
    Et je clique sur "Suivant"
    Et je décris le service "Vélocité Libre-service" avec l’identifiant "libre-service"
    Et je clique sur "Suivant"
    Et je remplis l’étape « Les utilisations prévues » du registre wallet
    Et je remplis l’étape « Les contacts » du registre wallet
    Alors la page contient "vous pourrez soumettre votre demande au registre, qui vérifiera votre organisation"
    Et la page ne contient pas "équipe d’instruction"

  @javascript
  Scénario: La barre « Précédent / Suivant » ne masque pas le champ qui a le focus (WCAG 2.4.11)
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je démarre une demande au registre wallet
    Et je clique sur "Enregistrer"
    Et la page contient "Brouillon enregistré à"
    Alors aucun élément ne passe sous la barre « Précédent / Suivant » quand je parcours l’étape au clavier dans une fenêtre basse
