# language: fr

Fonctionnalité: Consultation d'une demande d'habilitation ou d'une habilitation non-intègre issue de la v1
  A la suite de la migration de données de la v1, certaines demandes ou habilitations possédaient des données incomplète vis-à-vis des règles de validation et d'intégrité introduites en v2.
  Étant donné qu'il s'agit d'une contrainte soft et non hard (i.e. en base de données), les données ont été importés en v2, mais cependant certaines actions ne sont pas possibles car les données non-intègres ne sont pas géré. De ce fait, on empêche certaines actions d'être effectuées, telle que la réouverture.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte
    Et que j'ai 1 demande d'habilitation "API Entreprise" validée
    Et que cette demande est issue de la v1 et non intègre
    Et que je me rends sur cette demande d'habilitation

  Scénario: Il y a une bannière d'information concernant le caractère non-intègre issue de la v1 d'une habilitation
    Alors il y a un formulaire en une seule page
    Et il y a un message d'attention contenant "corrompues"

  Scénario: Je ne peux pas transférer une demande d'habilitation validée non-intègre issue de la v1 m'appartenant
    Alors il y a un formulaire en une seule page
    Et il n'y a pas de bouton "Transférer"

  Scénario: Je ne peux pas réouvrir une demande d'habilitation validée non-intègre issue de la v1 m'appartenant
    Alors il y a un formulaire en une seule page
    Et il n'y a pas de bouton "Mettre à jour"


