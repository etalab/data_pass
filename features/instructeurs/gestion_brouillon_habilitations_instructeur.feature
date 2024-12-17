# language: fr

Fonctionnalité: Instruction: gestion des demandes d'habilitations d'instructeur
  Un instructeur peut créer une demande d'habilitation dîte "d'instructeur" : celui-ci
  peut créer directement une demande d'habilitation à l'aide du formulaire par défaut
  et partager le lien à une personne pour que celle-ci récupère la demande déjà pré-remplie
  par les soins de l'instructeur, et la déposer comme une demande d'habilitation classique.

  Cette demande d'habilitation ne fait objet d'aucun potentiel filtrage sur le type d'entité.

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte

  Scénario: Je peux voir les demande d'habilitations d'instructeur depuis la page d'instruction
    Quand je vais sur la page instruction
    Et que j'ai une demande d'habilitation à partager pour "API Entreprise" intitulée "Super secret"
    Et que je clique sur "Liste des demandes d'habilitation à partager"
    Alors la page contient "Super secret"
    Et la page contient "API Entreprise"

