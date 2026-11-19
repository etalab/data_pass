# language: fr

Fonctionnalité: Démarrer un enregistrement au registre wallet
  Un agent d’un organisme public, ou un dirigeant d’entreprise que ProConnect certifie,
  démarre l’enregistrement de son organisation depuis la page de démarrage habituelle de DataPass,
  qui porte pour ce formulaire un second bouton « Me connecter avec ProConnect dirigeant ».
  Toute autre personne y voit le message de son cas, et l’introduction ne s’ouvre pas.

  Scénario: La page de démarrage habituelle porte le bouton dirigeant
    Quand je me rends sur la page de démarrage du registre wallet
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
    Et la page contient "S’identifier avec ProConnect"
    Et la page contient "Me connecter avec ProConnect dirigeant"

  Scénario: Les autres formulaires gardent la page de démarrage sans bouton dirigeant
    Quand je me rends sur le chemin "/formulaires/api-entreprise/demande/nouveau"
    Alors la page contient "Votre demande d’habilitation va se dérouler en 4 étapes"
    Et la page contient "Pour suivre vos demandes d’habilitations"
    Et la page contient "S’identifier avec ProConnect"
    Et la page ne contient pas "Me connecter avec ProConnect dirigeant"

  Scénario: Un agent public se connecte avec le bouton habituel et démarre sa demande
    Sachant que je suis un demandeur de la commune de Clamart
    Quand je me rends sur la page de démarrage du registre wallet
    Et que je clique sur "S’identifier avec ProConnect"
    Alors la page contient "Vous n’avez pas à prouver que vous pouvez engager votre administration"
    Et la page contient "Si votre service passe par un intermédiaire, vous ne pouvez pas encore l’enregistrer"
    Et la page contient "vous la déposerez après la soumission de la demande, pour obtenir vos certificats"
    Et la page ne contient pas "Le certificat d’accès du service"
    Et la page contient "Une fois votre demande soumise, le registre la vérifie sous 5 jours ouvrés."
    Quand je clique sur "Débuter ma demande"
    Alors la page contient "L’organisation"

  Scénario: Un dirigeant certifié par ProConnect arrive sur l’introduction
    Sachant que je suis dirigeant d’une entreprise privée
    Et que ProConnect certifie que je suis dirigeant de mon organisation
    Quand je me rends sur la page de démarrage du registre wallet
    Et que je clique sur "Me connecter avec ProConnect dirigeant"
    Alors la page contient "Vous n’avez pas à prouver que vous êtes dirigeant : ProConnect l’a vérifié à votre connexion"
    Et la page contient "Débuter ma demande"

  Scénario: Un agent public utilise le bouton dirigeant
    Sachant que je suis un demandeur de la commune de Clamart
    Quand je me rends sur la page de démarrage du registre wallet
    Et que je clique sur "Me connecter avec ProConnect dirigeant"
    Alors la page contient "Votre organisation relève du secteur public"
    Quand je me rends sur la page de démarrage du registre wallet
    Alors la page contient "Vous n’avez pas à prouver que vous pouvez engager votre administration"

  Scénario: Un dirigeant utilise le bouton des agents publics
    Sachant que je suis dirigeant d’une entreprise privée
    Quand je me rends sur la page de démarrage du registre wallet
    Et que je clique sur "S’identifier avec ProConnect"
    Alors la page contient "n’est pas un organisme public : seul son dirigeant peut l’enregistrer"
    Et la page ne contient pas "Débuter ma demande"

  Scénario: Le dirigeant choisit chez ProConnect une autre entreprise que celle de sa connexion
    Sachant que je suis dirigeant d’une entreprise privée
    Et que ProConnect certifie que je suis dirigeant d’une autre entreprise
    Quand je me rends sur la page de démarrage du registre wallet
    Et que je clique sur "Me connecter avec ProConnect dirigeant"
    Alors la page contient "L’entreprise certifiée n’est pas celle de votre connexion"
    Et la page contient "Me connecter avec ProConnect dirigeant"

  Scénario: Le dirigeant relance la certification après avoir choisi la mauvaise entreprise
    Sachant que je suis dirigeant d’une entreprise privée
    Et que ProConnect certifie que je suis dirigeant d’une autre entreprise
    Quand je me rends sur la page de démarrage du registre wallet
    Et que je clique sur "Me connecter avec ProConnect dirigeant"
    Et que ProConnect certifie que je suis dirigeant de mon organisation
    Et que je clique sur "Me connecter avec ProConnect dirigeant"
    Alors la page contient "Vous n’avez pas à prouver que vous êtes dirigeant"

  Scénario: ProConnect ne certifie pas le dirigeant
    Sachant que je suis dirigeant d’une entreprise privée
    Et que ProConnect ne certifie pas mon statut de dirigeant
    Quand je me rends sur la page de démarrage du registre wallet
    Et que je clique sur "Me connecter avec ProConnect dirigeant"
    Alors la page contient "ProConnect n’a pas pu certifier que vous dirigez"

  Scénario: ProConnect interrompt la certification
    Sachant que je suis dirigeant d’une entreprise privée
    Et que ProConnect interrompt la vérification de dirigeant
    Quand je me rends sur la page de démarrage du registre wallet
    Et que je clique sur "Me connecter avec ProConnect dirigeant"
    Alors la page contient "Bienvenue sur DataPass !"
    Et la page contient "ProConnect n’a pas pu certifier que vous dirigez"

  Scénario: L’organisation est fermée dans le répertoire Sirene
    Sachant que je suis un demandeur d'une organisation fermée
    Quand je me rends sur la page de démarrage du registre wallet
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
    Quand je me rends sur la page de démarrage du registre wallet
    Et que je clique sur "Me connecter avec ProConnect dirigeant"
    Et que je me rends sur la page de démarrage du registre wallet
    Alors la page contient "n’est pas un organisme public : seul son dirigeant peut l’enregistrer"
    Et la page ne contient pas "Débuter ma demande"
    Quand je me rends sur le chemin "/formulaires/registre-wallet/demande/commencer"
    Alors la page contient "n’est pas un organisme public : seul son dirigeant peut l’enregistrer"
    Et la page ne contient pas "Débuter ma demande"

  Scénario: La certification retenue n’ouvre plus l’introduction au bout d’une heure
    Sachant que je suis dirigeant d’une entreprise privée
    Et que ProConnect certifie que je suis dirigeant de mon organisation
    Quand je me rends sur la page de démarrage du registre wallet
    Et que je clique sur "Me connecter avec ProConnect dirigeant"
    Alors la page contient "Débuter ma demande"
    Quand une heure s’est écoulée depuis la certification
    Et que je me rends sur la page de démarrage du registre wallet
    Alors la page contient "n’est pas un organisme public : seul son dirigeant peut l’enregistrer"
    Et la page ne contient pas "Débuter ma demande"
    Quand je me rends sur le chemin "/formulaires/registre-wallet/demande/commencer"
    Alors la page contient "n’est pas un organisme public : seul son dirigeant peut l’enregistrer"

  Scénario: Une organisation dont le secteur n’est pas encore connu peut commencer sa demande
    Sachant que je suis dirigeant d’une entreprise privée
    Et que le répertoire Sirene n’a pas encore renseigné mon organisation
    Et que je me connecte
    Quand je me rends sur la page de démarrage du registre wallet
    Alors la page contient "Nous n’avons pas encore pu lire la catégorie juridique de votre organisation"
    Quand je clique sur "Débuter ma demande"
    Alors la page contient "L’organisation"
