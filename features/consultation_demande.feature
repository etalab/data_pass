# language: fr

Fonctionnalité: Consultation d'une demande d'habilitation
  Description des différents scénario de consultation en fonction de l'état de l'habilitation,
  du type de formulaire et de la relation entre l'utilisateur courant et l'habilitation
  cible: demandeur, appartenant à l'organisation ou mentionné.

  Seules les habilitations appartenant à l'utilisateur courant possède des actions de modifications.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je consulte une demande d'habilitation refusée m'appartenant
    Quand je me rends sur une demande d'habilitation "API Entreprise" refusée
    Alors il y a un message d'erreur contenant "a été refusée"
    Et il n'y a pas de bouton "Sauvegarder"
    Et il y a un formulaire en mode résumé

  Scénario: Je consulte une demande d'habilitation demandant des modifications m'appartenant
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modifier
    Alors il y a un bouton "Modifier"
    Et il y a un bouton "Soumettre la demande"
    Et il y a un message d'attention contenant "Veuillez inclure une preuve"
    Et il y a un formulaire en une seule page

  Scénario: Je consulte une demande d'habilitation simple en brouillon m'appartenant
    Quand je me rends sur une demande d'habilitation "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)" en brouillon
    Alors il y a un titre contenant "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)"
    Et il y a une bulle de messagerie
    Et il y a un formulaire en une seule page
    Et il y a un bouton "Enregistrer"

  Scénario: Je consulte une demande d'habilitation en plusieurs étapes en brouillon m'appartenant
    Quand je me rends sur une demande d'habilitation "API scolarité de l'élève" en brouillon
    Alors il y a un titre contenant "API scolarité de l'élève"
    Et il y a un formulaire en plusieurs étapes
    Et il y a un bouton "Enregistrer"

  Scénario: Je consulte une demande d'habilitation en plusieurs étapes en brouillon m'appartenant
    Quand je me rends sur une demande d'habilitation "API Entreprise" en brouillon
    Alors il y a un titre contenant "API Entreprise"
    Et il y a une bulle de messagerie
    Et il y a un formulaire en plusieurs étapes
    Et il y a un bouton "Suivant"

  Scénario: Je consulte une demande d'habilitation simple en brouillon de l'organisation
    Quand mon organisation a 1 demande d'habilitation "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)"
    Et que je me rends sur mon tableau de bord demandes
    Quand je sélectionne le filtre "Les autres demandes de l'organisation" pour "Filtrer par demandeur"
    Et que je clique sur "Rechercher"
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)"
    Et il n'y a pas de bulle de messagerie
    Et il y a un formulaire en mode résumé
    Et il n'y a pas de bouton "Enregistrer"

  Scénario: Je consulte une demande d'habilitation en plusieurs étapes en brouillon de l'organisation
    Quand mon organisation a 1 demande d'habilitation "Démarches du bouquet de services (service-public.fr)"
    Et que je me rends sur mon tableau de bord demandes
    Quand je sélectionne le filtre "Les autres demandes de l'organisation" pour "Filtrer par demandeur"
    Et que je clique sur "Rechercher"
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "Démarches du bouquet de services (service-public.fr)"
    Et il y a un formulaire en mode résumé
    Et il n'y a pas de bouton "Enregistrer"

  Scénario: Je consulte une demande d'habilitation en plusieurs étapes en brouillon de l'organisation
    Quand mon organisation a 1 demande d'habilitation "API Entreprise"
    Et que je me rends sur mon tableau de bord demandes
    Quand je sélectionne le filtre "Les autres demandes de l'organisation" pour "Filtrer par demandeur"
    Et que je clique sur "Rechercher"
    Alors je montre la page
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "API Entreprise"
    Et il y a un formulaire en mode résumé
    Et il n'y a pas de bouton "Enregistrer"

  Scénario: Je consulte une demande d'habilitation simple où je suis mentionné
    Quand je suis mentionné dans 1 demande d'habilitation "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)" en tant que "Administrateur métier"
    Et que je me rends sur mon tableau de bord demandes
    Quand je sélectionne le filtre "Je suis mentionné en contact" pour "Filtrer par demandeur"
    Et que je clique sur "Rechercher"
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)"
    Et il n'y a pas de bulle de messagerie
    Et il y a un formulaire en mode résumé
    Et il n'y a pas de bouton "Enregistrer"
    Et il y a un message d'info contenant "Vous avez été référencé comme administrateur local"

  Scénario: Je consulte une demande d'habilitation en plusieurs étapes où je suis mentionné
    Quand je suis mentionné dans 1 demande d'habilitation "Démarches du bouquet de services (service-public.fr)" en tant que "Administrateur métier"
    Et que je me rends sur mon tableau de bord demandes
    Quand je sélectionne le filtre "Je suis mentionné en contact" pour "Filtrer par demandeur"
    Et que je clique sur "Rechercher"
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "Démarches du bouquet de services (service-public.fr)"
    Et il y a un formulaire en mode résumé
    Et il n'y a pas de bouton "Enregistrer"
    Et il y a un message d'info contenant "Vous avez été référencé comme administrateur local"

  Scénario: Je consulte une demande d'habilitation en plusieurs étapes où je suis mentionné
    Quand je suis mentionné dans 1 demande d'habilitation "API Entreprise" en tant que "Contact technique"
    Et que je me rends sur mon tableau de bord demandes
    Quand je sélectionne le filtre "Je suis mentionné en contact" pour "Filtrer par demandeur"
    Et que je clique sur "Rechercher"
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "API Entreprise"
    Et il y a un formulaire en mode résumé
    Et il n'y a pas de bouton "Enregistrer"
    Et il y a un message d'info contenant "Vous avez été référencé comme contact technique"

  Scénario: Je consulte une habilitation où je suis mentionnée
    Quand je suis mentionné dans 1 demande d'habilitation "API Entreprise" en tant que "Contact technique"
    Et que cette demande a été "validée"
    Et que je me rends sur mon tableau de bord demandeur habilitations
    Quand je sélectionne le filtre "Je suis mentionné en contact" pour "Filtrer par demandeur"
    Et que je clique sur "Rechercher"
    Et que je clique sur "Consulter"
    Alors il y a un titre contenant "API Entreprise"
    Et il y a un formulaire en mode résumé
    Et il y a un message d'info contenant "Vous avez été référencé comme contact technique"

  Scénario: Je consulte la dernière habilitation validée dont la demande a été réouverte
    Quand j'ai 1 demande d'habilitation "API Entreprise" réouverte
    Et que je me rends sur l'habilitation validée
    Alors la page contient "Une mise à jour de cette habilitation est en cours"

  Scénario: Je consulte une ancienne habilitation validée dont la demande a été réouverte
    Quand j'ai 1 demande d'habilitation "API Entreprise" réouverte
    Et que cette demande a déjà été validée le 01/01/2024
    Et que cette demande a déjà été validée le 01/02/2024
    Et que je me rends sur l'habilitation validée du 01/01/2024
    Alors la page contient "Attention, vous consultez une version ancienne de cette habilitation"

  Scénario: Je consulte une habilitation sandbox validée dont la demande a obtenu une habilitation production
    Quand j'ai 1 demande d'habilitation "API Impôt Particulier" validée
    Et que je me rends sur mon tableau de bord habilitations
    Alors je montre la page
    Et que je me rends sur la première habilitation validée
    Alors la page ne contient pas "Attention, vous consultez une version ancienne de cette habilitation"
