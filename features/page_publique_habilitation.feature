# language: fr

Fonctionnalité: Consultation d'une demande d'habilitation via sa page public
  Chaque demande d'habilitation possède une page public accessible à n'importe quel internaute

  Scénario: Je peux consulter une page de demande d'habilitation sans être connectée
    Sachant qu'il existe une demande d'habilitation "API Entreprise" intitulée "Ma superbe demande"
    Et que je visite sa page publique
    Alors la page contient "API Entreprise"
    Et la page contient "Ma superbe demande"
