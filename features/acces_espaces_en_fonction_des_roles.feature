# language: fr

Fonctionnalité: Niveau d'accès aux différentes pages en fonction des rôles
  Scénario: En tant qu'utilisateur normal, je ne peux pas accéder à l'espace d'instruction
    Sachant que je suis un demandeur
    Et que je me connecte
    Et que je vais sur la page instruction
    Alors je suis sur la page "Demandes et habilitations"
    Et il y a un message d'erreur contenant "Vous n'avez pas le droit d'accéder à cette page"

  Scénario: En tant qu'instructeur, je peux accéder à la page d'instruction
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte
    Et que je vais sur la page instruction
    Alors je suis sur l'espace instruction

  Scénario: En tant que rapporteur, je peux accéder à la page d'instruction
    Sachant que je suis un rapporteur "API Entreprise"
    Et que je me connecte
    Et que je vais sur la page instruction
    Alors je suis sur l'espace instruction

  Scénario: En tant qu'instructeur, je ne peux pas accéder à la page d'administration
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte
    Et que je vais sur l'espace administrateur
    Alors je suis sur la page "Demandes et habilitations"
    Et il y a un message d'erreur contenant "Vous n'avez pas le droit d'accéder à cette page"

  Scénario: En tant que rapporteur, je ne peux pas accéder à la page d'administration
    Sachant que je suis un rapporteur "API Entreprise"
    Et que je me connecte
    Et que je vais sur l'espace administrateur
    Alors je suis sur la page "Demandes et habilitations"
    Et il y a un message d'erreur contenant "Vous n'avez pas le droit d'accéder à cette page"

  Scénario: En tant qu'administrateur, je peux accéder à l'espace administration
    Sachant que je suis un administrateur
    Et que je me connecte
    Et que je vais sur l'espace administrateur
    Alors je suis sur l'espace administrateur

