# language: fr

Fonctionnalité: Registre wallet, relire et soumettre sa demande d’enregistrement

  Scénario: L’agent public relit sa demande, puis la soumet au registre (CA1, CA2, CA8)
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand j’arrive au récapitulatif du registre wallet
    Alors la page contient "Vérifiez votre demande avant de la soumettre"
    Et la page contient "Le registre vérifie ensuite votre organisation sous 5 jours ouvrés."
    Et la page contient "Demandeur"
    Et la page contient "Agent de la commune, connecté par ProConnect avec le compte de son administration"
    Et la page ne contient pas "Se reconnecter et soumettre"
    Quand je coche les deux engagements du registre wallet
    Et je clique sur "Soumettre la demande d’enregistrement"
    Alors la page contient "La demande d’enregistrement de Vélocité Libre-service a été soumise avec succès"
    Et la page contient "Le registre la vérifie sous 5 jours ouvrés."
    Et la demande du registre wallet est en cours de vérification

  Scénario: Une case non cochée est signalée par la page (CA3)
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand j’arrive au récapitulatif du registre wallet
    Et je clique sur "Soumettre la demande d’enregistrement"
    Alors la page contient "Cochez les deux cases pour soumettre votre demande."
    Et la demande du registre wallet est toujours un brouillon

  Scénario: Une étape incomplète est listée, avec un lien pour la corriger (CA3)
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand j’arrive au récapitulatif du registre wallet
    Et la description du service de mon brouillon du registre wallet est vidée
    Et je coche les deux engagements du registre wallet
    Et je clique sur "Soumettre la demande d’enregistrement"
    Alors la page contient "Des étapes sont incomplètes"
    Quand je clique sur "Corriger l’étape 2 : le service"
    Alors la page contient "Étape 2/4"

  Scénario: Depuis le récapitulatif, le demandeur relance le chargement des informations de l’organisation (R10)
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand j’arrive au récapitulatif du registre wallet
    Et les informations de l’organisation de mon brouillon du registre wallet sont en cours de chargement
    Et je coche les deux engagements du registre wallet
    Et je clique sur "Soumettre la demande d’enregistrement"
    Alors la page contient "Des étapes sont incomplètes"
    Et la liste des étapes incomplètes précède le récapitulatif
    Quand je clique sur "Corriger l’étape 1 : l’organisation"
    Alors la page contient "Informations en cours de chargement"
    Quand je clique sur "Mettre à jour les informations de l’organisation"
    Alors la page contient "Les informations de votre organisation sont à jour."
    Et la page contient "COMMUNE DE CLAMART"
    Et la page ne contient pas "Informations en cours de chargement"

  @javascript
  Scénario: La mise à jour des informations de l’organisation reste active quand le bloc est modifié depuis le récapitulatif (R10)
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand j’arrive au récapitulatif du registre wallet
    Et les informations de l’organisation de mon brouillon du registre wallet sont en cours de chargement
    Et je modifie le bloc « L’organisation » de mon brouillon du registre wallet
    Alors la page contient "Nous récupérons les informations de votre organisation"
    Et le bouton "Enregistrer les modifications" est désactivé
    Quand je clique sur "Mettre à jour les informations de l’organisation"
    Alors la page contient "Les informations de votre organisation sont à jour."
    Et la page ne contient pas "Nous récupérons les informations de votre organisation"

  Scénario: Une demande soumise se relit sans pouvoir être modifiée (CA5)
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand j’arrive au récapitulatif du registre wallet
    Et je coche les deux engagements du registre wallet
    Et je clique sur "Soumettre la demande d’enregistrement"
    Et je reprends mon brouillon du registre wallet
    Alors la page contient "En cours de vérification"
    Et la page ne contient pas "Étape 1/4"
    Et la page ne contient pas "Brouillon enregistré"
    Et la page ne contient pas "Modifier"

  Scénario: Le dirigeant se reconnecte avec ProConnect, puis sa demande part au registre (CA9)
    Sachant que je suis un demandeur d'une entreprise
    Et que je me connecte
    Quand j’arrive au récapitulatif du registre wallet
    Alors la page contient "vous vous reconnecterez avec ProConnect"
    Et la page contient "Dirigeant de l’organisation, certifié par ProConnect"
    Quand je coche les deux engagements du registre wallet
    Et je clique sur "Se reconnecter et soumettre"
    Et je clique sur "Continuer vers ProConnect"
    Alors la page contient "a été soumise avec succès"
    Et la demande du registre wallet est en cours de vérification

  Scénario: ProConnect ne certifie plus le dirigeant au moment de soumettre (CA4)
    Sachant que je suis un demandeur d'une entreprise
    Et que je me connecte
    Quand j’arrive au récapitulatif du registre wallet
    Et je coche les deux engagements du registre wallet
    Et je clique sur "Se reconnecter et soumettre"
    Et ProConnect ne certifie pas mon statut de dirigeant
    Et je clique sur "Continuer vers ProConnect"
    Alors la page contient "Vous ne pouvez pas soumettre cette demande"
    Et la demande du registre wallet est toujours un brouillon

  Scénario: La reconnexion est interrompue chez ProConnect (CA10)
    Sachant que je suis un demandeur d'une entreprise
    Et que je me connecte
    Quand j’arrive au récapitulatif du registre wallet
    Et je coche les deux engagements du registre wallet
    Et je clique sur "Se reconnecter et soumettre"
    Et ProConnect interrompt la vérification de dirigeant
    Et je clique sur "Continuer vers ProConnect"
    Alors la page contient "Vous ne pouvez pas soumettre cette demande"
    Et la demande du registre wallet est toujours un brouillon
