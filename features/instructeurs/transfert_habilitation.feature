# language: fr

Fonctionnalité: Instruction: transfert de demande d'habilitation
  Un instructeur peut transférer une demande d'habilitation vers un autre utilisateur de la même organisation

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte

  Scénario: Je vois un bouton de transfert sur une demande validée
    Quand je me rends sur une demande d'habilitation "API Entreprise" validée
    Alors il y a un bouton "Transférer"

  Scénario: Je vois un bouton de transfert sur une demande soumise
    Quand je me rends sur une demande d'habilitation "API Entreprise" soumise
    Alors il y a un bouton "Transférer"

  Scénario: Je vois un bouton de transfert sur une demande réouverte
    Quand je me rends sur une demande d'habilitation "API Entreprise" réouverte
    Alors il y a un bouton "Transférer"

  Scénario: Je ne vois pas de bouton de transfert sur une demande en brouillon
    Quand je me rends sur une demande d'habilitation "API Entreprise" en brouillon
    Alors il n'y a pas de bouton "Transférer"

  @AvecCourriels
  Scénario: Je transfère une demande d'habilitation vers un autre utilisateur de la même organisation
    Sachant que "nouveau-demandeur@api.gouv.fr" appartient à mon organisation
    Et que je me rends sur une demande d'habilitation "API Entreprise" validée
    Et que je clique sur "Transférer"
    Et que je remplis "Email du nouveau demandeur" avec "nouveau-demandeur@api.gouv.fr"
    Et que je clique sur "Valider le transfert"
    Alors l'utilisateur "nouveau-demandeur@api.gouv.fr" possède une demande d'habilitation "API Entreprise"

  Scénario: Je tente de transférer une demande vers un utilisateur d'une autre organisation
    Sachant que "autre-demandeur@api.gouv.fr" appartient à une autre organisation
    Et que je me rends sur une demande d'habilitation "API Entreprise" validée
    Et que je clique sur "Transférer"
    Et que je remplis "Email du nouveau demandeur" avec "autre-demandeur@api.gouv.fr"
    Et que je clique sur "Valider le transfert"
    Alors il y a un message d'erreur contenant "doit appartenir à la même organisation"

  Scénario: Je tente de transférer une demande vers un utilisateur inexistant
    Quand je me rends sur une demande d'habilitation "API Entreprise" validée
    Et que je clique sur "Transférer"
    Et que je remplis "Email du nouveau demandeur" avec "inconnu@gouv.fr"
    Et que je clique sur "Valider le transfert"
    Alors il y a un message d'erreur contenant "Aucun utilisateur n'a été trouvé"
