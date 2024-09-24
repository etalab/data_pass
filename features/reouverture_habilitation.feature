# language: fr

Fonctionnalité: Réouverture d'une habilitation validée
  Une habilitation validée peut être réouverte par un demandeur. Celle-ci peut
  être ressoumise, revalidée ou refusée (ce qui annule les changements) et la 
  réouverture peut être annulée

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  @FlushJobQueue
  Scénario: Initialisation d'une réouverture d'une demande validée depuis le tableau de bord
    Quand j'ai 1 demande d'habilitation "API Entreprise" validée
    Et que je vais sur la page tableau de bord
    Et que je clique sur "Mettre à jour"
    Et que je clique sur "Mettre à jour l'habilitation"
    Alors je suis sur la page "API Entreprise"
    Et il y a un message de succès contenant "a bien été réouverte"
    Et un webhook avec l'évènement "reopen" est envoyé
    Et il y a un badge "Mise à jour"
    Et il y a un badge "Brouillon"
    Et la page ne contient pas "Archiver"
    Et la page ne contient pas "Récapitulatif de votre demande"
    Et il y a une mise en avant contenant "Mise à jour de l'habilitation"

  Scénario: Initialisation d'une réouverture d'une demande validée depuis la vue validée
    Quand j'ai 1 demande d'habilitation "API Entreprise" validée
    Et que je vais sur la page tableau de bord
    Et que je clique sur le premier "Consulter"
    Et que je clique sur "Mettre à jour"
    Et que je clique sur "Mettre à jour l'habilitation"
    Alors je suis sur la page "API Entreprise"
    Et il y a un message de succès contenant "a bien été réouverte"
    Et il y a un badge "Mise à jour"

  Scénario: Présence des badges d'une habilitation réouverte sur le tableau de bord
    Quand j'ai 1 demande d'habilitation "API Entreprise" réouverte
    Et que je vais sur la page tableau de bord
    Alors il y a un badge "Validée"
    Et il y a un badge "Brouillon"

  Scénario: Présence de la date de réouverture sur une habilitation réouverte sur le tableau de bord
    Quand j'ai 1 demande d'habilitation "API Entreprise" réouverte
    Et que je vais sur la page tableau de bord
    Alors la page contient la date du jour au format court

  Scénario: Consultation de l'habilitation validée associée à une réouverture
    Quand j'ai 1 demande d'habilitation "API Entreprise" réouverte
    Et que je vais sur la page tableau de bord
    Et que je clique sur le premier "Consulter"
    Alors je suis sur la page "API Entreprise"
    Et il y a un badge "Validée"
    Et il n'y a pas de bouton "Mettre à jour"
    Et il n'y a pas de bouton "Enregistrer"
    Et il y a un message d'info contenant "Une mise à jour de cette demande est en cours."

  Scénario: Consultation de la demande de mise à jour associée à une réouverture
    Quand j'ai 1 demande d'habilitation "API Entreprise" réouverte
    Et que je vais sur la page tableau de bord
    Et que je clique sur le dernier "Consulter"
    Alors je suis sur la page "API Entreprise"
    Et il y a un badge "Mise à jour"
    Et il y a un badge "Brouillon"
    Et il n'y a pas de bouton "Enregistrer"

  Scénario: Annulation d'une demande de réouverture
    Quand j'ai 1 demande d'habilitation "API Entreprise" réouverte
    Et que je vais sur la page tableau de bord
    Et que je clique sur le dernier "Consulter"
    Alors il y a un bouton "Annuler la demande de réouverture"
    Et que je clique sur "Annuler la demande de réouverture"
    Alors il y a un bouton "Annuler la réouverture de cette demande"
    Et que je clique sur "Annuler la réouverture de cette demande"
    Alors il y a un message de succès contenant "a été annulée"

  Scénario: Soumission d'une habilitation fraîchement réouverte
    Quand j'ai 1 demande d'habilitation "API Entreprise" réouverte
    Et que je vais sur la page tableau de bord
    Et que je clique sur le dernier "Consulter"
    Alors il y a un bouton "Annuler la demande de réouverture"
    Et que je clique sur "Soumettre"
    Alors il y a un message de succès contenant "soumise avec succès"
    Et il y a un badge "Validée"
    Et il y a un badge "En cours"
    Et que je clique sur le dernier "Consulter"
    Alors il n'y a pas de bouton "Annuler la demande de réouverture"

  @DisableBullet
  @FlushJobQueue
  Scénario: Soumission d'une habilitation réouverte qui a été refusée
    Quand j'ai 1 demande d'habilitation "API Entreprise" réouverte
    Et que cette demande a été "soumise"
    Et que cette demande a été "refusée"
    Et que je vais sur la page tableau de bord
    Et que je clique sur le dernier "Consulter"
    Alors il y a un badge "Validée"


