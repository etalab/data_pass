# language: fr

Fonctionnalité: Soumission depuis la page de résumé d'une demande en attente de modification
  Quand un demandeur soumet une demande en attente de modification depuis la page de
  résumé et que la soumission échoue, le message d'erreur doit être affiché.
  Ce comportement est critique car la page de résumé d'une demande en attente de
  modification utilise des onglets (turbo-frames), ce qui peut rendre le message
  d'erreur invisible si la réponse n'est pas gérée correctement.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  @javascript
  Scénario: L'erreur d'email non joignable est affichée ainsi que les onglets lors de la soumission depuis la page de résumé d'une demande à modifier
    Quand j'ai 1 demande d'habilitation "API Entreprise" en attente de modification
    Et qu'il y a l'email "jean.dupont.contact_technique@gouv.fr" marqué en tant que "non délivrable"
    Et que je me rends sur cette demande d'habilitation
    Et que je clique sur "Soumettre la demande d'habilitation"
    Alors il y a un message d'erreur contenant "Nous n’avons pas pu transmettre votre demande"
    Et je vois l'onglet "Demande"

  @javascript
  Scénario: L'erreur d'email non joignable est affichée ainsi que les onglets lors de la soumission depuis la page de résumé d'un draft
    Quand j'ai 1 demande d'habilitation "API Entreprise" en brouillon et rempli
    Et qu'il y a l'email "jean.dupont.contact_technique@gouv.fr" marqué en tant que "non délivrable"
    Et que je me rends sur la page résumé de cette demande
    Et que je clique sur "Soumettre la demande d'habilitation"
    Alors il y a un message d'erreur contenant "Nous n’avons pas pu transmettre votre demande"
    Et je ne vois pas l'onglet "Demande"
