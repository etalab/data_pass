# language: fr

Fonctionnalité: Détail d'un formulaire
  En tant qu'instructeur, je peux consulter le détail d'un formulaire
  afin de voir les informations associées à ce formulaire.

  Contexte:
    Soit un fournisseur de données "DINUM" existe
    Sachant que je suis un rapporteur "API Entreprise"
    Et que je me connecte

  Scénario: L'en-tête affiche le nom du formulaire avec le logo du fournisseur
    Quand je me rends sur le formulaire "API Entreprise"
    Alors la page contient "API Entreprise"

  Scénario: Le lien de retour mène vers la liste des formulaires
    Quand je me rends sur le formulaire "API Entreprise"
    Alors le lien retour mène vers la liste des formulaires

  Scénario: Je peux accéder au détail d'un formulaire depuis la liste
    Quand je me rends sur la liste des formulaires
    Et je clique sur "API Entreprise"
    Alors la page contient "API Entreprise"
    Et le lien retour mène vers la liste des formulaires

  Scénario: Le lien d'initiation de demande est visible pour un instructeur sur un type d'habilitation qui l'active
    Sachant que je suis un instructeur "API Entreprise"
    Quand je me rends sur le formulaire "API Entreprise"
    Alors la page contient "Initier une demande pour autrui"

  Scénario: Le lien d'initiation de demande n'est pas visible pour un rapporteur
    Quand je me rends sur le formulaire "API Entreprise"
    Alors la page ne contient pas "Initier une demande pour autrui"

  Scénario: Le lien d'initiation de demande n'est pas visible si la fonctionnalité n'est pas activée
    Soit un fournisseur de données "DILA" existe
    Sachant que je suis un instructeur "Démarches du bouquet de services (service-public.fr)"
    Quand je me rends sur le formulaire "Démarches du bouquet de services (service-public.fr)"
    Alors la page ne contient pas "Initier une demande pour autrui"
