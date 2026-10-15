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
    Et la page contient "Une fois soumise, votre demande est examinée par l’équipe Resana."
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
    Alors un email est envoyé contenant "a soumis une nouvelle demande d'habilitation"
