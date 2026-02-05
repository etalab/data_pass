# language: fr

Fonctionnalité: Création automatique d'habilitation FranceConnect pour API Particulier
  Lorsqu'une demande API Particulier avec modalité FranceConnect pour un éditeur certifié est validée,
  le système crée automatiquement deux habilitations : API Particulier et FranceConnect.

  Contexte:
    Sachant que je suis un instructeur "API Particulier"
    Et que je me connecte

  @FlushJobQueue
  Scénario: Validation crée une habilitation FranceConnect liée
    Sachant qu'il y a une demande API Particulier avec champs FranceConnect intégrés à modérer
    Quand je me rends sur cette demande d'habilitation
    Et je clique sur "Valider"
    Et je clique sur "Valider la demande d'habilitation"
    Alors je suis sur la page "Liste des demandes et habilitations"
    Et il y a 2 habilitations pour cette demande

  @FlushJobQueue
  Scénario: Validation sans champs FranceConnect crée une seule habilitation
    Sachant qu'il y a une demande API Particulier sans champs FranceConnect à modérer
    Quand je me rends sur cette demande d'habilitation
    Et je clique sur "Valider"
    Et je clique sur "Valider la demande d'habilitation"
    Alors je suis sur la page "Liste des demandes et habilitations"
    Et il y a 1 habilitation pour cette demande

  @FlushJobQueue
  Scénario: Validation avec FranceConnect déclenche un webhook FranceConnect
    Sachant qu'il y a une demande API Particulier avec champs FranceConnect intégrés à modérer
    Et qu'il existe un webhook activé pour FranceConnect avec l'URL "https://webhook.site/fc-test"
    Quand je me rends sur cette demande d'habilitation
    Et je clique sur "Valider"
    Et je clique sur "Valider la demande d'habilitation"
    Alors un webhook avec l'évènement "approve" est envoyé pour FranceConnect

  Scénario: L'habilitation FranceConnect liée n'est pas réouvrable
    Sachant qu'il y a une demande API Particulier avec champs FranceConnect intégrés validée
    Alors l'habilitation FranceConnect liée n'est pas réouvrable
