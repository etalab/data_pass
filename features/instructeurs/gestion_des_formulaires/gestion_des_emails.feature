# language: fr

Fonctionnalité: Gestion des emails automatiques d'un formulaire
  En tant qu'instructeur, je peux consulter la page des emails automatiques
  d'un formulaire.

  Contexte:
    Soit un fournisseur de données "DINUM" existe
    Sachant que je suis un rapporteur "API Entreprise"
    Et que je me connecte

  Scénario: J'accède à la page des emails automatiques depuis le détail du formulaire
    Quand je me rends sur le formulaire "API Entreprise"
    Et je clique sur "Voir les emails automatiques"
    Alors la page contient "Voir les emails automatiques"
    Et la page contient "API Entreprise"

  Scénario: La page liste les emails automatiques du formulaire
    Quand je me rends sur le formulaire "API Entreprise"
    Et je clique sur "Voir les emails automatiques"
    Alors la page contient "Évènement déclencheur"
    Et la page contient "Soumission d’une demande"
    Et la page contient "Responsable de traitement"
    Et la page contient "Nous accusons réception de votre demande d'habilitation"

  Scénario: Un manager voit le lien « Gérer les emails automatiques »
    Sachant que je suis un manager "API Entreprise"
    Quand je me rends sur le formulaire "API Entreprise"
    Et je clique sur "Gérer les emails automatiques"
    Alors la page contient "Gérer les emails automatiques"
