# language: fr

Fonctionnalité: Historique d’une demande soumise par API
  Quand un fournisseur de données soumet une demande par API, l’historique le dit
  clairement, au nom du demandeur, avec l’application qui a soumis.

  @DisableBullet
  Scénario: Le demandeur lit que sa demande a été soumise par API
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand j'ai 1 demande d'habilitation "API Entreprise" en brouillon et rempli
    Et que la demande est soumise par API via l’application "Portail API Entreprise"
    Et que je me rends sur cette demande d'habilitation
    Et que je clique sur "Historique"
    Alors la page contient "Demande soumise par API au nom de"
    Et la page contient "via l’application Portail API Entreprise"

  @DisableBullet
  Scénario: Un instructeur lit que la demande a été soumise par API
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte
    Quand il y a 1 demande d'habilitation "API Entreprise" en brouillon et rempli
    Et que la demande est soumise par API via l’application "Portail API Entreprise"
    Et que je me rends sur la dernière demande à instruire
    Et que je clique sur "Historique"
    Alors la page contient "Demande soumise par API au nom de"
    Et la page contient "via l’application Portail API Entreprise"

  @DisableBullet
  Scénario: Un instructeur lit que les notifications ont été désactivées par l’appel API
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte
    Quand il y a 1 demande d'habilitation "API Entreprise" en brouillon et rempli
    Et que la demande est soumise par API via l’application "Portail API Entreprise" sans notifications
    Et que je me rends sur la dernière demande à instruire
    Et que je clique sur "Historique"
    Alors la page contient "Les notifications DataPass ont été désactivées pour cet appel API."
