# language: fr

Fonctionnalité: Accès à la vérification du registre wallet
  Seules les personnes désignées vérifient les demandes d’enregistrement.

  Scénario: Un vérificateur ouvre la page du registre depuis le menu
    Sachant que je suis un vérificateur du registre wallet
    Et que je me connecte
    Alors la page ne contient pas de lien "Espace instruction"
    Quand je clique sur "Vérification"
    Alors le titre principal de la page contient "Demandes d’enregistrement"

  Scénario: Le retrait du rôle prend effet tout de suite
    Sachant que je suis un vérificateur du registre wallet
    Et que je me connecte
    Quand mon rôle de vérificateur est retiré
    Et que je me rends sur le chemin "/verification/registre-wallet"
    Alors je suis sur la page "Demandes et habilitations"
    Et il y a un message d'erreur contenant "Vous n'avez pas le droit d'accéder à cette page"
    Et la page ne contient pas de lien "Vérification"

  Scénario: Un manager de tous les services DINUM n’a pas accès
    Sachant que je suis un manager de tout "dinum"
    Et que je me connecte
    Quand je me rends sur le chemin "/verification/registre-wallet"
    Alors je suis sur la page "Demandes et habilitations"
    Et il y a un message d'erreur contenant "Vous n'avez pas le droit d'accéder à cette page"
    Et la page ne contient pas de lien "Vérification"
