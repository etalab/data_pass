# language: fr

Fonctionnalité: Instruction: gestion des demandes d'habilitations d'instructeur
  Un instructeur peut créer une demande d'habilitation dîte "d'instructeur" : celui-ci
  peut créer directement une demande d'habilitation à l'aide du formulaire par défaut
  et partager le lien à une personne pour que celle-ci récupère la demande déjà pré-remplie
  par les soins de l'instructeur, et la déposer comme une demande d'habilitation classique.

  Cette demande d'habilitation ne fait objet d'aucun filtrage sur le type d'entité et le lien entre
  l'usager et l'organisation.

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte
    Et que je vais sur la page instruction

  Scénario: Je peux voir les demande d'habilitations d'instructeur depuis la page d'instruction
    Quand j'ai une demande d'habilitation à partager pour "API Entreprise" intitulée "Super secret"
    Et que je clique sur "Demandes initiés par des instructeurs"
    Alors la page contient "Super secret"
    Et la page contient "API Entreprise"

  Scénario: Je peux créer une demande d'habilitation d'instructeur
    Quand je clique sur "Demandes initiés par des instructeurs"
    Et que je clique sur "Initier une nouvelle demande d'habilitation"
    Et que je clique sur "Démarrer le brouillon"
    Et que je remplis "Nom du projet" avec "Conquérir le monde"
    Et que je remplis "Description du projet" avec "Comment chaque soir"
    Et que je clique sur "Sauvegarder"

    Alors il y a un message de succès contenant "La demande d'habilitation a bien été sauvegardé"
    Et le champ "Nom du projet" contient "Conquérir le monde"
    Et le champ "Description du projet" contient "Comment chaque soir"

  Scénario: Si je suis instructeur de plusieurs type de demande, je peux choisir le type de demande que je veux
    Sachant que je suis un instructeur "API Particulier"
    Quand je clique sur "Demandes initiés par des instructeurs"
    Et que je clique sur "Initier une nouvelle demande d'habilitation"
    Alors la page contient "API Entreprise"
    Et la page contient "API Particulier"

  @javascript
  Scénario: Je peux choisir un formulaire spécifique lors de la création d'une demande d'habilitation d'instructeur
    Quand je clique sur "Demandes initiés par des instructeurs"
    Et que je clique sur "Initier une nouvelle demande d'habilitation"
    Et que je sélectionne "Marchés publics" pour "Sélectionner un formulaire"
    Alors la page contient "Simplifier le dépôt des candidatures"
    Quand je clique sur "Démarrer le brouillon"
    Alors le champ "URL du texte relatif au traitement" contient "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000037730589"
    Quand je remplis "Nom du projet" avec "Projet cantine"
    Et que je clique sur "Sauvegarder"
    Alors il y a un message de succès contenant "La demande d'habilitation a bien été sauvegardé"
    Et le champ "Nom du projet" contient "Projet cantine"
    Et le champ "URL du texte relatif au traitement" contient "https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000037730589"

  Scénario: Je peux mettre à jour une demande d'habilitation d'instructeur
    Quand j'ai une demande d'habilitation à partager pour "API Entreprise" intitulée "Super secret"
    Et que je clique sur "Demandes initiés par des instructeurs"
    Et que je clique sur "Modifier"
    Et que je remplis "Nom du projet" avec "Conquérir le monde"
    Et que je clique sur "Sauvegarder"
    Alors il y a un message de succès contenant "La demande d'habilitation a bien été mis à jour"
    Et le champ "Nom du projet" contient "Conquérir le monde"

  Scénario: Je peux supprimer une demande d'habilitation d'instructeur
    Quand j'ai une demande d'habilitation à partager pour "API Entreprise" intitulée "Super secret"
    Et que je clique sur "Demandes initiés par des instructeurs"
    Et que je clique sur "Supprimer"
    Alors il y a un message de succès contenant "La demande d'habilitation a bien été supprimé"
    Et la page ne contient pas "Super secret"
    Et je suis sur la page "Demandes initiés par des instructeurs"
