# language: fr

Fonctionnalité: Soumission d'une demande d'habilitation simple (sur une seule page)
  Une demande d'habilitation simple se fait sur une page unique, l'ensemble des interactions
  effectuées par le demandeur sont effectuées au sein de cette page.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: J'enregistre une demande d'habilitation
    Quand je démarre une nouvelle demande d'habilitation "Portail HubEE - Démarche CertDC"
    Alors je suis sur la page "Portail HubEE - Démarche CertDC"
    Et il y a un bouton "Soumettre la demande d'habilitation"
    Et il y a un bouton "Enregistrer les modifications"

  Scénario: Je soumets une demande d'habilitation invalide
    Quand je démarre une nouvelle demande d'habilitation "Portail HubEE - Démarche CertDC"
    Et que je clique sur "Soumettre la demande d'habilitation"
    Alors il y a un message d'erreur contenant "Une erreur est survenue lors de la soumission de la demande d'habilitation"
    Et il y a au moins une erreur sur un champ
    Et je suis sur la page "Portail HubEE - Démarche CertDC"

  Scénario: Je soumets une demande d'habilitation valide
    Quand je démarre une nouvelle demande d'habilitation "Portail HubEE - Démarche CertDC"
    Et que je remplis les informations du contact "Administrateur métier" avec :
      | Nom    | Prénom | Email               | Téléphone   | Fonction de l'administrateur système |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0836656565  | Administrateur métier                |
    Et que j'adhère aux conditions générales
    Et que je clique sur "Enregistrer les modifications"
    Et que je clique sur "Soumettre la demande d'habilitation"
    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Accueil"
