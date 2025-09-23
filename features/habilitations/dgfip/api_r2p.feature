# language: fr

Fonctionnalité: Redirection du formulaire API R2P vers le nouveau formulaire unifié SFIP/R2P
  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Le formulaire R2P est indisponible et propose le nouveau formulaire SFIP/R2P
    Quand je me rends sur le chemin "/demandes/api_r2p/nouveau"

    Alors la page contient "Ce formulaire n'est plus disponible"
    Et que je clique sur "Accéder au nouveau formulaire"
    Alors la page contient "Demander une habilitation à : API Courtier fonctionnel SFiP"
