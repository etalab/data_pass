# language: fr

Fonctionnalité: Instruction: consultation d'une demande d'habilitation et affichage de l'alerte sur le lien demandeur <-> organisation

  Un instructeur peut consulter une demande d'habilitation et y voir des informations relatives
  au lien entre le demandeur et organisation lorsque celui-ci n'est pas vérifié

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte

  Scénario: Il n'y a aucune alerte vis-à-vis du lien entre le demandeur et l'organisation si celui-ci est vérifié
    Quand il y a 1 demande d'habilitation "API Entreprise" en attente
    Et que le lien entre le demandeur et l'organisation est marqué comme "vérifié"
    Et que je me rends sur cette demande d'habilitation
    Alors la page ne contient pas "pas pu vérifier le lien entre"

  Scénario: Il y a une alerte vis-à-vis du lien entre le demandeur et l'organisation si celui-ci n'est pas vérifié
    Quand il y a 1 demande d'habilitation "API Entreprise" en attente
    Et que le lien entre le demandeur et l'organisation est marqué comme "non vérifié"
    Et que je me rends sur cette demande d'habilitation
    Alors il y a un message d'attention contenant "pas pu vérifier le lien entre"
