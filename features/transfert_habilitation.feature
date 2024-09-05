# language: fr

Fonctionnalité: Transfert de demandes d'habilitations par un utilisateur
  Un utilisateur peut transférer une demande d'habilitation à un autre utilisateur de la même organisation, et un utilisateur
  peut se transférer une demande d'habilitation de son organisation à lui-même

  Contexte:
    Sachant que je suis un demandeur pour l'organisation "Ville de Clamart"
    Et que je me connecte

  Scénario: Je vois un bouton de transfert d'habilitation sur une de mes demandes validée
    Quand je me rends sur une demande d'habilitation "API Entreprise" validée
    Alors il y a un bouton "Transférer"

  Scénario: Je vois un bouton de transfert d'habilitation sur une de mes demandes en brouillon
    Quand je me rends sur une demande d'habilitation "API Entreprise" en brouillon
    Alors il y a un bouton "Transférer"

  Scénario: Je vois un bouton de transfert d'habilitation sur une de mes demandes soumise
    Quand je me rends sur une demande d'habilitation "API Entreprise" soumise
    Alors il y a un bouton "Transférer"

  Scénario: Je vois un bouton de transfert d'habilitation sur une demande validée de mon organisation
    Quand je me rends sur une demande d'habilitation "API Entreprise" de l'organisation "Ville de Clamart" validée
    Alors il y a un bouton "Transférer"

  Scénario: Je ne vois pas de bouton de transfert d'habilitation sur une demande en brouillon de mon organisation
    Quand je me rends sur une demande d'habilitation "API Entreprise" de l'organisation "Ville de Clamart" en brouillon
    Alors il n'y a pas de bouton "Transférer"



  @AvecCourriels
  Scénario: Je transfère une de mes habilitations à un autre utilisateur de mon organisation
    Sachant que "nouveau-demandeur@api.gouv.fr" appartient à mon organisation
    Et que je me rends sur une demande d'habilitation "API Entreprise" validée
    Et que je clique sur "Transférer"
    Et que je remplis "Email du nouveau demandeur" avec "nouveau-demandeur@api.gouv.fr"
    Et que je clique sur "Valider le transfert"
    Alors il y a un message de succès contenant "transférée à l'utilisateur nouveau-demandeur@api.gouv.fr"
    Et un email est envoyé contenant "transférée" à "nouveau-demandeur@api.gouv.fr et demandeur@gouv.fr"

  Scénario: Je tente de transfèrer une de mes habilitations à un autre utilisateur qui n'est pas de mon organisation
    Sachant que "invalid-demandeur@api.gouv.fr" appartient à une autre organisation
    Et que je me rends sur une demande d'habilitation "API Entreprise" validée
    Et que je clique sur "Transférer"
    Et que je remplis "Email du nouveau demandeur" avec "invalid-demandeur@api.gouv.fr"
    Et que je clique sur "Valider le transfert"
    Alors il y a un message d'erreur contenant "pas à la même organisation"

  Scénario: Je tente de transférer une de mes habilitations à un autre utilisateur qui n'existe pas
    Sachant que je me rends sur une demande d'habilitation "API Entreprise" validée
    Et que je clique sur "Transférer"
    Et que je remplis "Email du nouveau demandeur" avec "inconnu@gouv.fr"
    Et que je clique sur "Valider le transfert"
    Alors il y a un message d'erreur contenant "ne possède pas de compte sur DataPass"



  @AvecCourriels
  Scénario: Je me transfère une des habilitations de mon organisation
    Quand je me rends sur une demande d'habilitation "API Entreprise" de l'organisation "Ville de Clamart" validée
    Et que je clique sur "Transférer"
    Et que je clique sur "Valider le transfert"
    Alors il y a un message de succès contenant "transférée sur votre compte"
    Et un email est envoyé contenant "transférée"
