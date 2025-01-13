# language: fr

Fonctionnalité: Instruction: historique habilitation
  Une habilitation possède un historique en fonction des actions des demandeurs et instructeurs

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte

  Scénario: Je vois les événements
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modérer
    Et je clique sur "Valider"
    Et je clique sur "Valider la demande d'habilitation"
    Et que je clique sur "Consulter"
    Et que je clique sur "Historique"
    Alors la page contient "a approuvé la demande"
    Et la page contient "a soumis la demande"

  @DisableBullet
  Scénario: Je vois un message simple indiquant la soumission d'une demande sans données pré-remplies
    Quand il y a 1 demande d'habilitation "API Entreprise" en attente
    Et que je vais sur la page instruction
    Et que je clique sur "Consulter"
    Et que je clique sur "Historique"
    Alors la page contient "a soumis la demande"

  @DisableBullet
  Scénario: Je vois les modifications apportées entre 2 soumissions pour un formulaire sans données pré-remplies
    Quand il y a 1 demande d'habilitation "API Entreprise" en attente
    Et que cette demande a été "sujet à modification"
    Et que cette demande a été modifiée avec les informations suivantes :
      | champ       | nouvelle valeur                |
      | intitule    | Nouvelle valeur de titre       |
      | description | Nouvelle valeur de description |
    Et que cette demande a été "soumise"
    Et que je vais sur la page instruction
    Et que je clique sur "Consulter"
    Et que je clique sur "Historique"
    Alors la page contient "Le champ Nom du projet a changé de \"Demande d'accès à la plateforme fournisseur\" en \"Nouvelle valeur de titre\""
    Et la page contient "Le champ Description du projet a changé de \"Description de la demande\" en \"Nouvelle valeur de description\""

  @DisableBullet
  Scénario: Je vois un message simple indiquant la soumission d'une demande après une instruction, sans modification du demandeur
    Quand il y a 1 demande d'habilitation "API Entreprise" en attente
    Et que cette demande a été "sujet à modification"
    Et que cette demande a été "soumise"
    Et que je vais sur la page instruction
    Et que je clique sur "Consulter"
    Et que je clique sur "Historique"
    Alors la page contient "a soumis la demande sans effectuer de changement"

  @DisableBullet
  Scénario: Je vois un message simple indiquant la soumission d'une demande avec données pré-remplies non modifiées
    Quand il y a 1 demande d'habilitation "Solution Portail des aides" en brouillon
    Et que cette demande a été modifiée avec les informations suivantes :
      | champ                                   | nouvelle valeur                     |
      | responsable_traitement_family_name      | Dupont                              |
      | responsable_traitement_given_name       | Jacques                             |
      | responsable_traitement_email            | responsable_traitement@test.fr      |
      | responsable_traitement_job_title        | Responsable traitement              |
      | responsable_traitement_phone_number     | 0836656565                          |
      | delegue_protection_donnees_family_name  | Dupond                              |
      | delegue_protection_donnees_given_name   | Jean                                |
      | delegue_protection_donnees_email        | delegue_protection_donnees@test.fr  |
      | delegue_protection_donnees_job_title    | DPO                                 |
      | delegue_protection_donnees_phone_number | 0836656565                          |
    Et que cette demande a été "soumise"
    Et que je vais sur la page instruction
    Et que je clique sur "Consulter"
    Et que je clique sur "Historique"
    Alors la page contient "a soumis la demande sans effectuer de changement sur les données pré-remplies"

  @DisableBullet
  Scénario: Je vois les modifications apportées sur des données pré-remplies lors de la première soumission
    Quand il y a 1 demande d'habilitation "Solution Portail des aides" en brouillon
    Et que cette demande a été modifiée avec les informations suivantes :
      | champ                                   | nouvelle valeur                     |
      | contact_technique_email                 | tech@test.fr                        |
      | responsable_traitement_family_name      | Dupont                              |
      | responsable_traitement_given_name       | Jacques                             |
      | responsable_traitement_email            | responsable_traitement@test.fr      |
      | responsable_traitement_job_title        | Responsable traitement              |
      | responsable_traitement_phone_number     | 0836656565                          |
      | delegue_protection_donnees_family_name  | Dupond                              |
      | delegue_protection_donnees_given_name   | Jean                                |
      | delegue_protection_donnees_email        | delegue_protection_donnees@test.fr  |
      | delegue_protection_donnees_job_title    | DPO                                 |
      | delegue_protection_donnees_phone_number | 0836656565                          |
    Et que cette demande a été "soumise"
    Et que je vais sur la page instruction
    Et que je clique sur "Consulter"
    Et que je clique sur "Historique"
    Alors la page contient "Les données suivantes ont été modifiées par rapport aux informations pré-remplies du formulaire"

  @DisableBullet
  Scénario: Je vois un lien vers l'habilitation sur l'évènement de validation
    Quand il y a 1 demande d'habilitation "Solution Portail des aides" soumise
    Et que cette demande a été "validée"
    Et que je vais sur la page instruction
    Et que je clique sur "Consulter"
    Et que je clique sur "Historique"
    Alors la page contient un lien vers "demandes/.+/habilitations/.+"
