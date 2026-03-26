# language: fr

Fonctionnalité: Consultation de demandes et habilitations avec une organisation dont le lien n'est pas vérifié
  En tant qu'usager lié à une organisation dont le lien n'est pas vérifié, je ne peux pas consulter
  les autres demandes de l'organisation, mais je peux consulter mes propres habilitations

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte via ProConnect avec l'identité "DGFIP" qui renvoi l'organisation "Ville de Clamart"
    Et que je clique sur "CLAMART"
    Et que j'ai 1 demande d'habilitation "API Particulier" en brouillon
    Et que j'ai 1 demande d'habilitation "FranceConnect" validée
    Et que mon organisation a 1 demande d'habilitation "API Entreprise" en brouillon
    Et que mon organisation a 1 demande d'habilitation "API CaptchEtat" validée

  Scénario: Je ne peux pas voir les demandes de mon organisation sur mon tableau de bord
    Quand je me rends sur mon tableau de bord demandes
    Alors la page ne contient pas "API Entreprise"
    Et il y a un message d'info contenant "pourrez pas consulter l’ensemble des demandes et habilitations de l’organisation"

  Scénario: Je ne peux pas consulter une demande de mon organisation
    Quand je me rends sur la dernière demande "API Entreprise"
    Alors je suis sur la page "Demandes et habilitations"
    Et il y a un message d'erreur contenant "pas le droit"

  Scénario: Je ne peux pas voir les habilitations de mon organisation sur mon tableau de bord
    Quand je me rends sur mon tableau de bord habilitations
    Alors la page ne contient pas "API CaptchEtat"
    Et il y a un message d'info contenant "pourrez pas consulter l’ensemble des demandes et habilitations de l’organisation"

  Scénario: Je ne peux pas consulter une habilitation de mon organisation
    Quand je me rends sur la dernière demande "API CaptchEtat"
    Alors je suis sur la page "Demandes et habilitations"
    Et il y a un message d'erreur contenant "pas le droit"

  Scénario: Je peux consulter ma propre habilitation même si mon lien avec mon organisation n'est pas vérifié
    Quand j'ai 1 habilitation "API Entreprise" active
    Et mon organisation n'est pas vérifiée
    Et je visite la page de mon habilitation
    Alors il y a un formulaire en mode résumé non modifiable

  Scénario: Je ne peux pas consulter directement l'habilitation d'un autre membre de mon organisation non vérifiée
    Quand je me rends sur la dernière habilitation "API CaptchEtat"
    Alors je suis sur la page "Demandes et habilitations"
    Et il y a un message d'erreur contenant "pas le droit"
