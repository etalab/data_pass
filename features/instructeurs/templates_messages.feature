# language: fr

Fonctionnalité: Instruction: templates de messages
  Un manager peut créer et gérer des templates de messages pour faciliter
  les demandes de modifications et les refus d'habilitations. Les instructeurs
  et reporters peuvent consulter ces templates.

  Scénario: Un manager peut accéder à la liste des templates
    Sachant que je suis un manager "API Entreprise"
    Et que je me connecte
    Quand je me rends sur la page des templates de messages pour "API Entreprise"
    Alors la page contient "Modèles de message"

  Scénario: Un manager peut créer un template de demande de modifications
    Sachant que je suis un manager "API Entreprise"
    Et que je me connecte
    Quand je me rends sur la page des templates de messages pour "API Entreprise"
    Et que je clique sur "Nouveau modèle"
    Et que je sélectionne "Demande de modifications" pour "Type de modèle"
    Et que je remplis "Titre" avec "Informations manquantes"
    Et que je remplis "Contenu" avec "Bonjour, il manque des informations sur votre demande %{demande_intitule}. Voir : %{demande_url}"
    Et que je clique sur "Enregistrer"
    Alors il y a un message de succès contenant "Le modèle a été créé avec succès"
    Et la page contient "Informations manquantes"

  Scénario: Un manager peut créer un template de refus
    Sachant que je suis un manager "API Entreprise"
    Et que je me connecte
    Quand je me rends sur la page des templates de messages pour "API Entreprise"
    Et que je clique sur le premier "Nouveau modèle"
    Et que je sélectionne "Refus" pour "Type de modèle"
    Et que je remplis "Titre" avec "Organisation non éligible"
    Et que je remplis "Contenu" avec "Votre organisation n'est pas éligible pour cette API."
    Et que je clique sur "Enregistrer"
    Alors il y a un message de succès contenant "Le modèle a été créé avec succès"
    Et la page contient "Organisation non éligible"

  Scénario: Un manager peut éditer un template
    Sachant que je suis un manager "API Entreprise"
    Et que je me connecte
    Sachant qu'il existe un template de message "Informations manquantes" pour "API Entreprise"
    Quand je me rends sur la page des templates de messages pour "API Entreprise"
    Et que j'ouvre l'accordéon "API Entreprise - Demande de modifications - Informations manquantes"
    Et que je clique sur "Modifier"
    Et que je remplis "Titre" avec "Documents manquants"
    Et que je clique sur "Enregistrer"
    Alors il y a un message de succès contenant "Le modèle a été mis à jour avec succès"
    Et la page contient "Documents manquants"

  Scénario: Un manager peut supprimer un template
    Sachant que je suis un manager "API Entreprise"
    Et que je me connecte
    Sachant qu'il existe un template de message "Informations manquantes" pour "API Entreprise"
    Quand je me rends sur la page des templates de messages pour "API Entreprise"
    Et que j'ouvre l'accordéon "API Entreprise - Demande de modifications - Informations manquantes"
    Et que je clique sur "Supprimer"
    Alors il y a un message de succès contenant "Le modèle a été supprimé avec succès"
    Et la page ne contient pas "Informations manquantes"

  Scénario: Un manager peut prévisualiser un template
    Sachant que je suis un manager "API Entreprise"
    Et que je me connecte
    Sachant qu'il existe un template de message avec le contenu "Voir %{demande_url}" pour "API Entreprise"
    Quand je me rends sur la page des templates de messages pour "API Entreprise"
    Et que j'ouvre l'accordéon "API Entreprise - Demande de modifications"
    Alors la page contient "Voir http://localhost:3000/demandes/9001"

  Scénario: Un instructeur peut consulter les templates mais pas les modifier
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte
    Sachant qu'il existe un template de message "Informations manquantes" pour "API Entreprise"
    Quand je me rends sur la page des templates de messages pour "API Entreprise"
    Alors la page contient "Informations manquantes"
    Et la page ne contient pas "Nouveau modèle"

  @javascript
  Scénario: Un instructeur peut utiliser un template lors d'une demande de modifications
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte
    Sachant qu'il existe un template de message "Informations manquantes" avec le contenu "Il manque des infos sur %{demande_intitule}" pour "API Entreprise"
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modérer
    Et que je clique sur "Instruire la demande"
    Et que je clique sur "Demander des modifications"
    Et que je sélectionne "Informations manquantes" dans le sélecteur de templates
    Alors le champ "Raison" contient "Il manque des infos sur"

  @javascript
  Scénario: Un instructeur peut utiliser un template lors d'un refus
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte
    Sachant qu'il existe un template de message "Organisation non éligible" avec le contenu "Vous n'êtes pas éligible" pour "API Entreprise"
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modérer
    Et que je clique sur "Instruire la demande"
    Et que je clique sur "Refuser"
    Et que je sélectionne "Organisation non éligible" dans le sélecteur de templates
    Alors le champ "Raison" contient "Vous n'êtes pas éligible"

  Scénario: On ne peut pas créer plus de 3 templates du même type
    Sachant que je suis un manager "API Entreprise"
    Et que je me connecte
    Sachant qu'il existe 3 templates de type "Refus" pour "API Entreprise"
    Quand je me rends sur la page des templates de messages pour "API Entreprise"
    Et que je clique sur le premier "Nouveau modèle"
    Et que je sélectionne "Refus" pour "Type de modèle"
    Et que je remplis "Titre" avec "Quatrième template"
    Et que je remplis "Contenu" avec "Contenu du template"
    Et que je clique sur "Enregistrer"
    Alors la page contient "Vous ne pouvez pas créer plus de 3 modèles"

  Scénario: Un template avec des variables invalides ne peut pas être créé
    Sachant que je suis un manager "API Entreprise"
    Et que je me connecte
    Quand je me rends sur la page des templates de messages pour "API Entreprise"
    Et que je clique sur le premier "Nouveau modèle"
    Et que je sélectionne "Refus" pour "Type de modèle"
    Et que je remplis "Titre" avec "Template invalide"
    Et que je remplis "Contenu" avec "Bonjour %{variable_invalide}"
    Et que je clique sur "Enregistrer"
    Alors la page contient "contient des variables invalides"
