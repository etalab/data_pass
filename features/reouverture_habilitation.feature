# language: fr

Fonctionnalité: Réouverture d'une habilitation validée
  Une habilitation validée peut être réouverte par un demandeur. Celle-ci peut
  être resoumisse, revalidée ou refusée (ce qui annule les changements).

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Initialisation d'une réouverture d'une demande validée
    Quand j'ai 1 demande d'habilitation "API Entreprise" validée
    Et que je vais sur la page tableau de bord
    Et que je clique sur "Mettre à jour"
    Alors je suis sur la page "API Entreprise"
    Et il y a un message de succès contenant "a bien été réouverte"
    Et la page contient "Réouverture de la demande"
    Et il y a un badge "Mise à jour"
    Et il y a un badge "Brouillon"
    Et la page ne contient pas "Archiver"
    Et la page ne contient pas "Récapitulatif de votre demande"

  Scénario: Consultation de l'habilitation validée associée à une réouverture
    Quand j'ai 1 demande d'habilitation "API Entreprise" réouverte
    Et que je vais sur la page tableau de bord
    Et que je clique sur le premier "Consulter"
    Alors je suis sur la page "API Entreprise"
    Et il y a un badge "Validée"
    Et il n'y a pas de bouton "Enregistrer"

  Scénario: Consultation de la demande de mise à jour associée à une réouverture
    Quand j'ai 1 demande d'habilitation "API Entreprise" réouverte
    Et que je vais sur la page tableau de bord
    Et que je clique sur le dernier "Consulter"
    Alors je suis sur la page "API Entreprise"
    Et il y a un badge "Mise à jour"
    Et il y a un badge "Brouillon"
    Et il y a un bouton "Enregistrer"
