# language: fr

Fonctionnalité: Demande du rôle d’administrateur Resana
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Le formulaire figure dans la liste des formulaires
    Quand je me rends sur le chemin "/demandes"
    Alors la page contient "Attribution du rôle d’administrateur d’une organisation dans Resana"

  Scénario: L’introduction présente le rôle, l’engagement et les étapes
    Quand je veux remplir une demande pour "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Alors la page contient "Rôle administrateur Resana"
    Et la page contient "paramétrer l’espace Resana de votre organisation"
    Et la page contient "archiver les données de votre organisation"
    Et la page contient "« Administrateur de l’organisation »"
    Et la page contient "CGU Resana"
    Et la page contient "support-resana@numerique.gouv.fr"
    Et la page contient "Votre engagement"
    Et la page contient "Une fois soumise, votre demande est examinée par un agent de la DINUM."
    Et la page contient "Le cadre juridique"
    Et la page contient "Les personnes impliquées"

  Scénario: Je soumets une demande complète
    Quand je démarre une nouvelle demande d'habilitation "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Et je remplis le cadre juridique et les personnes impliquées de la demande Resana
    Alors la page contient "conditions générales d’utilisation de Resana"
    Quand j'adhère aux conditions générales
    Et je coche "Je confirme que le délégué à la protection des données de mon organisation est informé de ma demande."
    Et je clique sur "Soumettre la demande d'habilitation"
    Alors il y a un message de succès contenant "soumise avec succès"

  Scénario: La demande n’est pas soumise sans accepter les CGU Resana
    Quand je démarre une nouvelle demande d'habilitation "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Et je remplis le cadre juridique et les personnes impliquées de la demande Resana
    Et je coche "Je confirme que le délégué à la protection des données de mon organisation est informé de ma demande."
    Et je clique sur "Soumettre la demande d'habilitation"
    Alors il y a un message d'erreur contenant "conditions générales"

  @AvecCourriels
  Scénario: À la validation, le demandeur et le DPO sont informés
    Quand je démarre une nouvelle demande d'habilitation "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Et je remplis le cadre juridique et les personnes impliquées de la demande Resana
    Et j'adhère aux conditions générales
    Et je coche "Je confirme que le délégué à la protection des données de mon organisation est informé de ma demande."
    Et je clique sur "Soumettre la demande d'habilitation"
    Et un instructeur a validé la demande d'habilitation
    Alors un email est envoyé contenant "vous a désigné(e) comme" à "dupont.jacques@gouv.fr"

  @AvecCourriels
  Scénario: À la soumission, les instructeurs Resana sont notifiés
    Quand je démarre une nouvelle demande d'habilitation "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Et je remplis le cadre juridique et les personnes impliquées de la demande Resana
    Et il existe un instructeur pour cette demande d'habilitation
    Et j'adhère aux conditions générales
    Et je coche "Je confirme que le délégué à la protection des données de mon organisation est informé de ma demande."
    Et je clique sur "Soumettre la demande d'habilitation"
    Alors un email est envoyé contenant "a soumis une nouvelle demande d'habilitation pour Attribution du rôle d’administrateur d’une organisation dans Resana sur DataPass"

  Scénario: La certification suffit à valider le cadre juridique
    Quand je démarre une nouvelle demande d'habilitation "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Alors la page contient "La DINUM attribue le rôle d’administrateur Resana aux seuls agents habilités par leur hiérarchie à l’exercer pour leur organisation."
    Quand je sélectionne "Établissement public administratif" pour "Nature juridique de votre structure"
    Et je remplis "Organisations Resana concernées" avec "DINUM"
    Et je coche "Je certifie être habilité par ma hiérarchie à exercer le rôle d’administrateur Resana pour cette organisation"
    Et je clique sur "Suivant"
    Alors la page contient "Délégué à la protection des données"

  Scénario: Une lettre de la DSI suffit à valider le cadre juridique
    Quand je démarre une nouvelle demande d'habilitation "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Et je sélectionne "Service déconcentré de l’État" pour "Nature juridique de votre structure"
    Et je remplis "Organisations Resana concernées" avec "DINUM"
    Et je remplis "Fournissez une lettre de votre DSI ou DNUM attestant ce droit" avec le fichier "spec/fixtures/dummy.pdf"
    Et je clique sur "Suivant"
    Alors la page contient "Délégué à la protection des données"

  Scénario: Sans certification ni lettre, le cadre juridique est bloqué
    Quand je démarre une nouvelle demande d'habilitation "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Et je sélectionne "Établissement public administratif" pour "Nature juridique de votre structure"
    Et je clique sur "Suivant"
    Alors il y a un message d'erreur contenant "cochez la certification ou fournissez une lettre de votre DSI ou DNUM"

  Scénario: Sans nature juridique, le cadre juridique est bloqué
    Quand je démarre une nouvelle demande d'habilitation "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Et je coche "Je certifie être habilité par ma hiérarchie à exercer le rôle d’administrateur Resana pour cette organisation"
    Et je clique sur "Suivant"
    Alors il y a un message d'erreur contenant "Nature juridique de votre structure doit être rempli(e)"

  Scénario: Sans organisation Resana, le cadre juridique est bloqué
    Quand je démarre une nouvelle demande d'habilitation "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Alors la page contient "Pour quelle(s) organisation(s) Resana demandez-vous le rôle d’administrateur ?"
    Et la page contient "Une organisation par ligne"
    Quand je sélectionne "Établissement public administratif" pour "Nature juridique de votre structure"
    Et je coche "Je certifie être habilité par ma hiérarchie à exercer le rôle d’administrateur Resana pour cette organisation"
    Et je clique sur "Suivant"
    Alors il y a un message d'erreur contenant "Organisations Resana concernées doit être rempli(e)"

  Scénario: Une lettre qui n’est pas un PDF est refusée
    Quand je démarre une nouvelle demande d'habilitation "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Et je sélectionne "Établissement public administratif" pour "Nature juridique de votre structure"
    Et je remplis "Fournissez une lettre de votre DSI ou DNUM attestant ce droit" avec le fichier "spec/fixtures/dummy.xlsx"
    Et je clique sur "Suivant"
    Alors il y a au moins une erreur sur un champ

  Scénario: La liste des natures juridiques ne propose aucune collectivité territoriale
    Quand je démarre une nouvelle demande d'habilitation "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Alors la page ne contient pas "Collectivité"
    Et la page ne contient pas "Commune"

  Scénario: Le résumé affiche la nature juridique, l’engagement et la lettre
    Quand je démarre une nouvelle demande d'habilitation "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Et je sélectionne "Établissement public administratif" pour "Nature juridique de votre structure"
    Et je remplis "Organisations Resana concernées" avec "DINUM"
    Et je coche "Je certifie être habilité par ma hiérarchie à exercer le rôle d’administrateur Resana pour cette organisation"
    Et je remplis "Fournissez une lettre de votre DSI ou DNUM attestant ce droit" avec le fichier "spec/fixtures/dummy.pdf"
    Et je clique sur "Suivant"
    Et je remplis les personnes impliquées de la demande Resana
    Alors la page contient "Établissement public administratif"
    Et la page contient "Organisations Resana concernées"
    Et la page contient "DINUM"
    Et la page contient "Habilitation à exercer le rôle"
    Et la page contient "Le demandeur certifie être habilité par sa hiérarchie"
    Et la page contient "dummy.pdf"

  Scénario: L’étape des personnes impliquées présente le DPO puis le responsable métier
    Quand je démarre une nouvelle demande d'habilitation "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Et je remplis le cadre juridique de la demande Resana
    Alors la page contient "Les personnes renseignées ici seront contactées en temps voulu selon leur implication dans la démarche."
    Et la carte de contact "Délégué à la protection des données" contient "informé de votre accès aux données personnelles des utilisateurs Resana"
    Et la carte de contact "Délégué à la protection des données" ne propose pas de bouton "C'est moi"
    Et la carte de contact "Responsable métier" contient "recevra les accès administrateur"
    Et la carte de contact "Responsable métier" propose un bouton "C'est moi"
    Et la page ne contient pas "Contact technique"

  @javascript
  Scénario: « C’est moi » remplit le responsable métier avec mes informations
    Quand je démarre une nouvelle demande d'habilitation "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Et je remplis le cadre juridique de la demande Resana
    Et je clique sur "C'est moi"
    Alors un champ contient "demandeur@gouv.fr"
    Et un champ contient "Adjoint au Maire"

  Scénario: Le poste du responsable métier est obligatoire
    Quand je démarre une nouvelle demande d'habilitation "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Et je remplis le cadre juridique de la demande Resana
    Et je remplis les informations du contact "Délégué à la protection des données" avec :
      | Nom    | Prénom  | Email                  | Téléphone  |
      | Dupont | Jacques | dupont.jacques@gouv.fr | 0836656565 |
    Et je remplis les informations du contact "Responsable métier" avec :
      | Nom    | Prénom | Email               | Téléphone  |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0836656565 |
    Et je clique sur "Suivant"
    Alors il y a un message d'erreur contenant "Fonction du responsable métier doit être rempli(e)"

  Scénario: Un e-mail de DPO invalide est signalé
    Quand je démarre une nouvelle demande d'habilitation "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Et je remplis le cadre juridique de la demande Resana
    Et je remplis les informations du contact "Délégué à la protection des données" avec :
      | Nom    | Prénom  | Email        | Téléphone  |
      | Dupont | Jacques | pas-un-email | 0836656565 |
    Et je remplis les informations du contact "Responsable métier" avec :
      | Nom    | Prénom | Email               | Téléphone  | Poste occupé                   |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0836656565 | Chef de projet                 |
    Et je clique sur "Suivant"
    Alors il y a un message d'erreur contenant "Email du délégué à la protection des données"

  Scénario: Un téléphone qui n’est pas un numéro français est signalé
    Quand je démarre une nouvelle demande d'habilitation "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Et je remplis le cadre juridique de la demande Resana
    Et je remplis les informations du contact "Délégué à la protection des données" avec :
      | Nom    | Prénom  | Email                  | Téléphone  |
      | Dupont | Jacques | dupont.jacques@gouv.fr | 123        |
    Et je remplis les informations du contact "Responsable métier" avec :
      | Nom    | Prénom | Email               | Téléphone  | Poste occupé                   |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0836656565 | Chef de projet                 |
    Et je clique sur "Suivant"
    Alors il y a un message d'erreur contenant "doit être un numéro de téléphone français"

  Scénario: Le récapitulatif indique qui reçoit les accès administrateur
    Quand je démarre une nouvelle demande d'habilitation "Attribution du rôle d’administrateur d’une organisation dans Resana"
    Et je remplis le cadre juridique et les personnes impliquées de la demande Resana
    Alors la page contient "Responsable métier · reçoit les accès administrateur"
