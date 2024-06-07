# language: fr

Fonctionnalité: Consultation d'une demande d'habilitation en tant que reporter
  Un reporter peut se retrouver à consulter une demande d'habilitation via le lien utiliser par
  un utilisateur normal.

  Contexte:
    Sachant que je suis un rapporteur "API Entreprise"
    Et que je me connecte

  Scénario: Je consulte une demande d'habilitation où je suis reporter via un lien direct
    Quand je me rends via l'espace usager sur une demande d'habilitation "API Entreprise"
    Alors la page contient "API Entreprise"
    Et la page contient "Les informations renseignées par le demandeur"

  Scénario: Je consulte une demande d'habilitation où je ne suis pas reporter via un lien direct
    Quand je me rends via l'espace usager sur une demande d'habilitation "API Particulier"
    Alors il y a un message d'erreur contenant "Vous n'avez pas le droit d'accéder à cette page"



