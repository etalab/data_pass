# language: fr

Fonctionnalité: Métadonnées posées par le fournisseur de données via l’API
  Les métadonnées servent au fournisseur de données à reconnaître ses demandes.
  Elles ne sont montrées ni au demandeur ni à l’instructeur, et n’apparaissent
  pas dans l’historique.

  @DisableBullet
  Scénario: Le demandeur ne voit pas les métadonnées de sa demande
    Sachant que je suis un demandeur
    Et que je me connecte
    Quand j'ai 1 demande d'habilitation "API Entreprise" en brouillon et rempli
    Et que le fournisseur de données pose par API la métadonnée "campagne" à "migration-editeur-x"
    Et que la demande est soumise par API via l’application "Portail API Entreprise"
    Et que je me rends sur cette demande d'habilitation
    Alors la page ne contient pas "migration-editeur-x"
    Et je clique sur "Historique"
    Alors la page ne contient pas "migration-editeur-x"

  @DisableBullet
  Scénario: L’instructeur ne voit pas les métadonnées de la demande
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte
    Quand il y a 1 demande d'habilitation "API Entreprise" en brouillon et rempli
    Et que le fournisseur de données pose par API la métadonnée "campagne" à "migration-editeur-x"
    Et que la demande est soumise par API via l’application "Portail API Entreprise"
    Et que je me rends sur la dernière demande à instruire
    Alors la page ne contient pas "migration-editeur-x"
    Et je clique sur "Historique"
    Alors la page ne contient pas "migration-editeur-x"
