# language: fr

Fonctionnalité: Démarrer un enregistrement au registre wallet
  Un agent d’un organisme public, ou un dirigeant d’entreprise que ProConnect certifie,
  démarre l’enregistrement de son organisation depuis la page de démarrage habituelle de DataPass.
  L’arbre d’éligibilité lui a d’abord demandé qui il est : la page de démarrage rappelle sa réponse
  et ne porte qu’un bouton ProConnect, qui ouvre le parcours dirigeant quand il a répondu dirigeant.
  Toute autre personne y voit le message de son cas, et l’introduction ne s’ouvre pas.

  Scénario: La page de démarrage rappelle la réponse et ne porte qu’un bouton
    Quand je me rends sur la page de démarrage du registre wallet en répondant "un agent public"
    Alors la page contient "Vous souhaitez enregistrer votre organisation au registre des parties utilisatrices du wallet"
    Et la page contient "Votre enregistrement va se dérouler en 4 étapes"
    Et la page contient "Déclarer votre service et ses utilisations prévues"
    Et la page contient "Être vérifié par le registre"
    Et la page contient "Recevoir vos certificats"
    Et la page contient "5 jours ouvrés"
    Et la page contient "Pour enregistrer votre organisation"
    Et la page ne contient pas "Votre demande d’habilitation"
    Et la page ne contient pas "Être habilité"
    Et la page ne contient pas "Pour suivre vos demandes d’habilitations"
    Et la page contient "Vous avez répondu : un agent d’une administration ou d’une collectivité"
    Et la page contient "S’identifier avec ProConnect"
    Et la page contient "Changer de réponse"
    Et la page ne contient pas "Me connecter avec ProConnect dirigeant"

  Scénario: Les autres formulaires gardent la page de démarrage sans bouton dirigeant
    Quand je me rends sur le chemin "/formulaires/api-entreprise/demande/nouveau"
    Alors la page contient "Votre demande d’habilitation va se dérouler en 4 étapes"
    Et la page contient "Pour suivre vos demandes d’habilitations"
    Et la page contient "S’identifier avec ProConnect"
    Et la page ne contient pas "Vous avez répondu"

  Scénario: Un agent public se connecte avec le bouton habituel et démarre sa demande
    Sachant que je suis un demandeur de la commune de Clamart
    Quand je me rends sur la page de démarrage du registre wallet en répondant "un agent public"
    Et que je clique sur "S’identifier avec ProConnect"
    Alors la page contient "Vous n’avez pas à prouver que vous pouvez engager votre administration"
    Et la page contient "Si votre service passe par un intermédiaire, vous ne pouvez pas encore l’enregistrer"
    Et la page contient "vous la déposerez après la soumission de la demande, pour obtenir vos certificats"
    Et la page ne contient pas "Le certificat d’accès du service"
    Et la page contient "Une fois votre demande soumise, le registre la vérifie sous 5 jours ouvrés."
    Quand je clique sur "Débuter ma demande"
    Alors la page contient "Quelle organisation enregistrez-vous ?"

  Scénario: Un dirigeant certifié par ProConnect arrive sur l’introduction
    Sachant que je suis dirigeant d’une entreprise privée
    Et que ProConnect certifie que je suis dirigeant de mon organisation
    Quand je me rends sur la page de démarrage du registre wallet en répondant "le dirigeant d’une entreprise"
    Et que je clique sur "S’identifier avec ProConnect"
    Alors la page contient "Vous n’avez pas à prouver que vous êtes dirigeant : ProConnect l’a vérifié à votre connexion"
    Et la page contient "Débuter ma demande"

  Scénario: Un agent public utilise le bouton dirigeant
    Sachant que je suis un demandeur de la commune de Clamart
    Quand je me rends sur la page de démarrage du registre wallet en répondant "le dirigeant d’une entreprise"
    Et que je clique sur "S’identifier avec ProConnect"
    Alors la page contient "Votre organisation relève du secteur public"
    Quand je me rends sur la page de démarrage du registre wallet
    Alors la page contient "Vous n’avez pas à prouver que vous pouvez engager votre administration"

  Scénario: Un dirigeant utilise le bouton des agents publics
    Sachant que je suis dirigeant d’une entreprise privée
    Quand je me rends sur la page de démarrage du registre wallet en répondant "un agent public"
    Et que je clique sur "S’identifier avec ProConnect"
    Alors la page contient "n’est pas un organisme public : seul son dirigeant peut l’enregistrer"
    Et la page ne contient pas "Débuter ma demande"

  Scénario: Le dirigeant choisit chez ProConnect une autre entreprise que celle de sa connexion
    Sachant que je suis dirigeant d’une entreprise privée
    Et que ProConnect certifie que je suis dirigeant d’une autre entreprise
    Quand je me rends sur la page de démarrage du registre wallet en répondant "le dirigeant d’une entreprise"
    Et que je clique sur "S’identifier avec ProConnect"
    Alors la page contient "L’entreprise certifiée n’est pas celle de votre connexion"
    Et la page contient "Vous avez répondu : le dirigeant d’une entreprise"

  Scénario: Le dirigeant relance la certification après avoir choisi la mauvaise entreprise
    Sachant que je suis dirigeant d’une entreprise privée
    Et que ProConnect certifie que je suis dirigeant d’une autre entreprise
    Quand je me rends sur la page de démarrage du registre wallet en répondant "le dirigeant d’une entreprise"
    Et que je clique sur "S’identifier avec ProConnect"
    Et que ProConnect certifie que je suis dirigeant de mon organisation
    Et que je clique sur "S’identifier avec ProConnect"
    Alors la page contient "Vous n’avez pas à prouver que vous êtes dirigeant"

  Scénario: ProConnect ne certifie pas le dirigeant
    Sachant que je suis dirigeant d’une entreprise privée
    Et que ProConnect ne certifie pas mon statut de dirigeant
    Quand je me rends sur la page de démarrage du registre wallet en répondant "le dirigeant d’une entreprise"
    Et que je clique sur "S’identifier avec ProConnect"
    Alors la page contient "ProConnect n’a pas pu certifier que vous dirigez"

  Scénario: ProConnect interrompt la certification
    Sachant que je suis dirigeant d’une entreprise privée
    Et que ProConnect interrompt la vérification de dirigeant
    Quand je me rends sur la page de démarrage du registre wallet en répondant "le dirigeant d’une entreprise"
    Et que je clique sur "S’identifier avec ProConnect"
    Alors la page contient "Bienvenue sur DataPass !"
    Et la page contient "ProConnect n’a pas pu certifier que vous dirigez"

  Scénario: L’organisation est fermée dans le répertoire Sirene
    Sachant que je suis un demandeur d'une organisation fermée
    Quand je me rends sur la page de démarrage du registre wallet en répondant "un agent public"
    Et que je clique sur "S’identifier avec ProConnect"
    Alors la page contient "est fermée dans le répertoire Sirene"
    Et la page ne contient pas "Débuter ma demande"

  Scénario: L’adresse directe du démarrage ne contourne pas la page de démarrage
    Sachant que je suis dirigeant d’une entreprise privée
    Et que je me connecte
    Quand je me rends sur le chemin "/formulaires/registre-wallet/demande/commencer"
    Alors la page contient "n’est pas un organisme public : seul son dirigeant peut l’enregistrer"

  Scénario: Un dirigeant resté connecté sans certification ne rouvre pas l’introduction par son adresse
    Sachant que je suis dirigeant d’une entreprise privée
    Et que ProConnect interrompt la vérification de dirigeant
    Quand je me rends sur la page de démarrage du registre wallet en répondant "le dirigeant d’une entreprise"
    Et que je clique sur "S’identifier avec ProConnect"
    Et que je me rends sur la page de démarrage du registre wallet
    Alors la page contient "n’est pas un organisme public : seul son dirigeant peut l’enregistrer"
    Et la page ne contient pas "Débuter ma demande"
    Quand je me rends sur le chemin "/formulaires/registre-wallet/demande/commencer"
    Alors la page contient "n’est pas un organisme public : seul son dirigeant peut l’enregistrer"
    Et la page ne contient pas "Débuter ma demande"

  Scénario: La certification retenue ouvre encore l’introduction après une reconnexion
    Sachant que je suis dirigeant d’une entreprise privée
    Et que ProConnect certifie que je suis dirigeant de mon organisation
    Quand je me rends sur la page de démarrage du registre wallet en répondant "le dirigeant d’une entreprise"
    Et que je clique sur "S’identifier avec ProConnect"
    Alors la page contient "Débuter ma demande"
    Quand je quitte DataPass puis m’y reconnecte
    Et que je me rends sur la page de démarrage du registre wallet
    Alors la page contient "Débuter ma demande"

  Scénario: ProConnect qui ne certifie plus le dirigeant lui retire l’introduction
    Sachant que je suis dirigeant d’une entreprise privée
    Et que ProConnect certifie que je suis dirigeant de mon organisation
    Quand je me rends sur la page de démarrage du registre wallet en répondant "le dirigeant d’une entreprise"
    Et que je clique sur "S’identifier avec ProConnect"
    Alors la page contient "Débuter ma demande"
    Sachant que ProConnect ne certifie pas mon statut de dirigeant
    Quand je me rends sur la page de vérification de dirigeant
    Et que je clique sur "Vérifier avec ProConnect"
    Et que je me rends sur la page de démarrage du registre wallet
    Alors la page contient "n’est pas un organisme public : seul son dirigeant peut l’enregistrer"
    Et la page ne contient pas "Débuter ma demande"
    Quand je me rends sur le chemin "/formulaires/registre-wallet/demande/commencer"
    Alors la page contient "n’est pas un organisme public : seul son dirigeant peut l’enregistrer"

  Scénario: Une interruption de ProConnect laisse la certification retenue
    Sachant que je suis dirigeant d’une entreprise privée
    Et que ProConnect certifie que je suis dirigeant de mon organisation
    Quand je me rends sur la page de démarrage du registre wallet en répondant "le dirigeant d’une entreprise"
    Et que je clique sur "S’identifier avec ProConnect"
    Sachant que ProConnect interrompt la vérification de dirigeant
    Quand je me rends sur la page de vérification de dirigeant
    Et que je clique sur "Vérifier avec ProConnect"
    Et que je me rends sur la page de démarrage du registre wallet
    Alors la page contient "Débuter ma demande"

  Scénario: Une organisation dont le secteur n’est pas encore connu peut commencer sa demande
    Sachant que je suis dirigeant d’une entreprise privée
    Et que le répertoire Sirene n’a pas encore renseigné mon organisation
    Et que je me connecte
    Quand je me rends sur la page de démarrage du registre wallet
    Alors la page contient "Nous n’avons pas encore pu lire la catégorie juridique de votre organisation"
    Quand je clique sur "Débuter ma demande"
    Alors la page contient "Quelle organisation enregistrez-vous ?"

  @javascript
  Scénario: Un dirigeant certifié passe par l’arbre et arrive à la première étape
    Sachant que je suis dirigeant d’une entreprise privée
    Et que ProConnect certifie que je suis dirigeant de mon organisation
    Quand je me rends sur l’arbre d’éligibilité du registre wallet
    Alors la page contient "Enregistrer votre organisation au registre du portefeuille européen"
    Et la page contient "Votre réponse détermine la façon de vous connecter."
    Quand je choisis "Le dirigeant d’une entreprise"
    Alors la page contient "ProConnect vous demandera de vous identifier avec FranceConnect"
    Quand je clique sur "Commencer l’enregistrement"
    Alors la page contient "Vous avez répondu : le dirigeant d’une entreprise"
    Quand je clique sur "S’identifier avec ProConnect"
    Alors la page contient "Vous n’avez pas à prouver que vous êtes dirigeant : ProConnect l’a vérifié à votre connexion"
    Quand je clique sur "Débuter ma demande"
    Alors la page contient "Quelle organisation enregistrez-vous ?"

  @javascript
  Scénario: Un agent public passe par l’arbre et arrive à la première étape
    Sachant que je suis un demandeur de la commune de Clamart
    Quand je me rends sur l’arbre d’éligibilité du registre wallet
    Et je choisis "Un agent d’une administration ou d’une collectivité"
    Alors la page contient "Connectez-vous avec ProConnect, avec le compte de votre administration."
    Quand je clique sur "Commencer l’enregistrement"
    Alors la page contient "Vous avez répondu : un agent d’une administration ou d’une collectivité"
    Quand je clique sur "S’identifier avec ProConnect"
    Alors la page contient "Vous n’avez pas à prouver que vous pouvez engager votre administration"
    Quand je clique sur "Débuter ma demande"
    Alors la page contient "Quelle organisation enregistrez-vous ?"

  @javascript
  Scénario: Une association est renvoyée vers le support, sans bouton de connexion
    Quand je me rends sur l’arbre d’éligibilité du registre wallet
    Et je choisis "Une association"
    Alors la page contient "ProConnect ne certifie pas encore les dirigeants d’associations"
    Et la page ne contient pas "Commencer l’enregistrement"

  @javascript
  Scénario: La page de démarrage ramène à l’arbre pour changer de réponse
    Quand je me rends sur l’arbre d’éligibilité du registre wallet
    Et je choisis "Un agent d’une administration ou d’une collectivité"
    Et je clique sur "Commencer l’enregistrement"
    Et je clique sur "Changer de réponse"
    Alors la page contient "Êtes-vous :"

  Scénario: L’adresse du formulaire mène d’abord à l’arbre
    Quand je me rends sur la page de démarrage du registre wallet
    Alors la page contient "Votre réponse détermine la façon de vous connecter."
    Et la page ne contient pas "Bienvenue sur DataPass !"

  Scénario: Une réponse dirigeant tapée à la main ne change pas l’introduction d’un agent public
    Sachant que je suis un demandeur de la commune de Clamart
    Et que je me connecte
    Quand je me rends sur le chemin "/formulaires/registre-wallet/demande/nouveau?parcours=dirigeant"
    Alors la page contient "Vous n’avez pas à prouver que vous pouvez engager votre administration"

  Scénario: Une réponse dirigeant tapée à la main n’ouvre pas l’introduction sans certification
    Sachant que je suis dirigeant d’une entreprise privée
    Et que je me connecte
    Quand je me rends sur le chemin "/formulaires/registre-wallet/demande/nouveau?parcours=dirigeant"
    Alors la page contient "n’est pas un organisme public : seul son dirigeant peut l’enregistrer"
    Et la page ne contient pas "Débuter ma demande"
