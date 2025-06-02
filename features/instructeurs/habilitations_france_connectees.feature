# language: fr

Fonctionnalité: Instruction: consultation des habilitations FranceConnectées
  Un instructeur de FranceConnect peut voir les habilitations FranceConnectées associées

  Contexte:
    Sachant que je suis un instructeur "FranceConnect"
    Et que je me connecte

  Scénario: Je vois l'onglet Habilitations FranceConnectées associées sur une demande FranceConnect ayant des habilitations FranceConnectées
    Quand il y a une demande d'habilitation "FranceConnect" validée avec une habilitation FranceConnectée
    Et que je me rends sur cette demande d'habilitation
    Alors la page contient "Habilitations FranceConnectées"

  Scénario: Je ne vois pas l'onglet Habilitations FranceConnectées associées sur une demande FranceConnect sans habilitations FranceConnectées
    Sachant qu'il y a 1 demande d'habilitation "FranceConnect" validée
    Et que je me rends sur cette demande d'habilitation
    Alors la page ne contient pas "Habilitations FranceConnectées"
