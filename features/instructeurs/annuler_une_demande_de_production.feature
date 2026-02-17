# language: fr

Fonctionnalité: Instruction: annuler une demande de production
  Un instructeur peut annuler une demande de production d'un usager

  Contexte:
    Sachant que je suis un instructeur "API Impôt Particulier"
    Et que je suis un instructeur "API Particulier"
    Et que je me connecte

  Scénario: Je peux annuler une demande de production soumise
    Quand il y a 1 demande d'habilitation "API Impôt Particulier" à l'étape "Production" soumise
    Et que je me rends sur cette demande d'habilitation
    Alors il y a un bouton "Annuler la demande de production"

  Scénario: Je ne peux pas annuler une demande qui n'est pas en production
    Quand je me rends sur une demande d'habilitation "API Particulier" à modérer
    Alors il n'y a pas de bouton "Annuler la demande de production"

  Scénario: J'annule une demande de production
    Quand il y a 1 demande d'habilitation "API Impôt Particulier" à l'étape "Production" soumise
    Et que je me rends sur cette demande d'habilitation
    Et que je clique sur "Annuler la demande de production"
    Et que je clique sur "Confirmer l'annulation"
    Alors je suis sur la page "Liste des demandes et habilitations"
