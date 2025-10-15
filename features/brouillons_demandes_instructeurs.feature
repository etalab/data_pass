# language: fr

Fonctionnalité: Finalisation d'un brouillon de demande d'habilitation
  En tant que demandeur, je peux finaliser un brouillon de demande d'habilitation
  à l'aide d'un lien reçu par email.
  Lorsque je clique sur le lien, je suis redirigé vers la demande d'habilitation
  et j'ai la possibilité de finaliser la demande.
  Si je le fais, je peux ensuite modifier la demande et l'envoyer à l'instructeur.

  Contexte:
    Sachant que je suis un demandeur

  Scénario: Je peux finaliser un brouillon de demande d'habilitation en me connectant avec la même adresse email
    Quand on m'a invité à remplir une demande d'habilitation intitulée "Projet de formation"
    Et que je me rends sur cette invitation à remplir une demande d'habilitation
    Et que je clique sur "S’identifier avec ProConnect"
    Et que je clique sur "Finaliser cette demande"
    Alors la page contient "Étape 1 sur"

  Scénario: Je ne peux pas finaliser un brouillon de demande d'habilitation si je ne me connecte pas avec la même adresse email
    Quand il y a un brouillon de demande d'habilitation initiée pour l'usager "autre-usager@gouv.fr"
    Et que je me rends sur cette invitation à remplir une demande d'habilitation
    Et que je clique sur "S’identifier avec ProConnect"
    Alors il y a un message d'erreur contenant "pour un autre usager"

  Scénario: Je ne peux pas finaliser un brouillon de demande d'habilitation si celle-ci a déjà été finalisée
    Quand on m'a invité à remplir une demande d'habilitation intitulée "Projet de formation"
    Et que ce brouillon de demande d'habilitation a déjà été finalisée
    Et que je me rends sur cette invitation à remplir une demande d'habilitation
    Alors il y a un message d'erreur contenant "a déjà été finalisée"

