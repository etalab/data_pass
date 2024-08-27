# language: fr

Fonctionnalité: Interactions sur une demande d'habilitation simple (sur une seule page)
  Une demande d'habilitation simple se fait sur une page unique, l'ensemble des interactions
  effectuées par le demandeur sont effectuées au sein de cette page.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: J'enregistre une demande d'habilitation
    Quand je démarre une nouvelle demande d'habilitation "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)"
    Et que je clique sur "Enregistrer les modifications"
    Alors je suis sur la page "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)"
    Et il y a un message de succès contenant "a été sauvegardé"
    Et il y a un bouton "Continuer vers le résumé"
    Et il y a un bouton "Enregistrer les modifications"

  Scénario: Je veux me rendre au résumé d'une demande d'habilitation invalide
    Quand je démarre une nouvelle demande d'habilitation "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)"
    Et que je clique sur "Enregistrer les modifications"
    Et que je clique sur "Continuer vers le résumé"
    Alors il y a un message d'erreur contenant "Une erreur est survenue lors de la sauvegarde"
    Et il y a au moins une erreur sur un champ
    Et je suis sur la page "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)"
    Et il n'y a pas de formulaire en mode résumé

  Scénario: Je veux me rendre au résumé d'une demande d'habilitation valide
    Quand je démarre une nouvelle demande d'habilitation "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)"
    Et que je remplis les informations du contact "Administrateur métier" avec :
      | Nom    | Prénom | Email               | Téléphone   | Fonction de l'administrateur système |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0836656565  | Administrateur métier                |
    Et que je clique sur "Enregistrer les modifications"
    Et que je clique sur "Continuer vers le résumé"
    Alors je suis sur la page "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)"
    Et il y a un formulaire en mode résumé
    Et il y a un bouton "Supprimer"
    Et il n'y a pas de bouton "Enregistrer"

  Scénario: Je soumets une demande d'habilitation valide en omettant les conditions générales
    Quand je démarre une nouvelle demande d'habilitation "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)"
    Et que je remplis les informations du contact "Administrateur métier" avec :
      | Nom    | Prénom | Email               | Téléphone   | Fonction de l'administrateur système |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0836656565  | Administrateur métier                |
    Et que je clique sur "Enregistrer les modifications"
    Et que je clique sur "Continuer vers le résumé"
    Et que je clique sur "Soumettre la demande"
    Alors il y a un message d'erreur contenant "Une erreur est survenue lors de la soumission de la demande d'habilitation"
    Et je suis sur la page "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)"
    Et il y a un formulaire en mode résumé

  Scénario: Je soumets une demande d'habilitation valide en cochant les conditions générales
    Quand je démarre une nouvelle demande d'habilitation "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)"
    Et que je remplis les informations du contact "Administrateur métier" avec :
      | Nom    | Prénom | Email               | Téléphone   | Fonction de l'administrateur système |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0836656565  | Administrateur métier                |
    Et que je clique sur "Enregistrer les modifications"
    Et que je clique sur "Continuer vers le résumé"
    Et que j'adhère aux conditions générales
    Et que je clique sur "Soumettre la demande"
    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"

  @FlushJobQueue
  Scénario: Je soumets une demande d'habilitation valide émettant des webhooks
    Quand je me rends sur une demande d'habilitation "Solution ASTRE GF" en brouillon et rempli
    Et que je clique sur "Continuer vers le résumé"
    Et que j'adhère aux conditions générales
    Et que je clique sur "Soumettre la demande"
    Alors il y a un message de succès contenant "soumise avec succès"
    Et je suis sur la page "Demandes et habilitations"
    Et un webhook avec l'évènement "submit" est envoyé

  Scénario: Je démarre une demande d'habilitation avec des données pré-remplies
    Quand je veux remplir une demande pour "API Entreprise" via le formulaire "Dématérialisation des marchés publics" de l'éditeur "SETEC"
    Et que je clique sur "Débuter ma demande"
    Alors un champ contient "contact-setec@yopmail.com"

  @javascript
  Scénario: Je démarre une demande avec un contact à remplir et je clique sur "C'est moi"
    Quand je démarre une nouvelle demande d'habilitation "Démarche Certificats de Décès Électroniques Dématérialisés (CertDc)"
    Et que je clique sur "C'est moi"
    Alors un champ contient "Dupont"

