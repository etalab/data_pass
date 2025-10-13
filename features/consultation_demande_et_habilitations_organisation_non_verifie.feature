# language: fr

Fonctionnalité: Consultation de demandes et habilitations avec une organisation dont le lien n'est pas vérifié
  En tant qu'usager lié à une organisation dont le lien n'est pas vérifié, je ne peux pas consulter
  les autres demandes de l'organisation

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte via ProConnect avec l'identité "DGFIP" qui renvoi l'organisation "Ville de Clamart"
    Et que je clique sur "CLAMART"
    Et que j'ai 9 demandes d'habilitation "API Particulier" en brouillon
    Et que j'ai 9 demandes d'habilitation "FranceConnect" validée
    Et que mon organisation a 1 demande d'habilitation "API Entreprise" en brouillon
    Et que mon organisation a 1 demande d'habilitation "API CaptchEtat" validée

  Scénario: Je ne peux pas voir les demandes de mon organisation sur mon tableau de bord
    Quand je me rends sur mon tableau de bord demandes
    Alors la page ne contient pas "API Entreprise"
    Et il y a un message d'attention contenant "consulter les autres demandes ou habilitations de cette organisation"

  Scénario: Je ne peux pas consulter une demande de mon organisation
    Quand je me rends sur la dernière demande "API Entreprise"
    Alors je suis sur la page "Demandes et habilitations"
    Et il y a un message d'erreur contenant "pas le droit"

  Scénario: Je ne peux pas voir les habilitations de mon organisation sur mon tableau de bord
    Quand je me rends sur mon tableau de bord habilitations
    Alors la page ne contient pas "API CaptchEtat"
    Et il y a un message d'attention contenant "consulter les autres demandes ou habilitations de cette organisation"

  Scénario: Je ne peux pas consulter une habilitation de mon organisation
    Quand je me rends sur la dernière demande "API CaptchEtat"
    Alors je suis sur la page "Demandes et habilitations"
    Et il y a un message d'erreur contenant "pas le droit"
