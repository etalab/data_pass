# language: fr

Fonctionnalité: Consultation d'une demande d'habilitation ayant subit une mise à jour globale
  Si un ensemble de demande a subit une mise à jour globale, une modale est affichée
  pour informer l'utilisateur qu'une mise à jour a été effectuée. Cette modale ne s'affiche qu'une seule fois.

  Contexte:
    Sachant que je suis un demandeur
    Et que je me connecte

  Scénario: Je consulte une habilitation m'appartenant n'ayant pas eu de mise à jour globale
    Quand j'ai 1 demande d'habilitation "API Entreprise" validée
    Et que je me rends sur cette demande d'habilitation
    Alors il n'y a pas de modale contenant "mise à jour globale"

  Scénario: Je consulte une habilitation de mon organisation pour la première fois depuis une mise à jour globale
    Quand mon organisation a 1 demande d'habilitation "API Entreprise" validée
    Et qu'une mise à jour globale a été effectuée sur les demandes d'habilitations "API Entreprise"
    Et que je me rends sur cette demande d'habilitation
    Alors il n'y a pas de modale contenant "mise à jour globale"

  @javascript
  Scénario: Je consulte une habilitation m'appartenant pour la première fois depuis une une mise à jour globale
    Quand j'ai 1 demande d'habilitation "API Entreprise" validée
    Et qu'une mise à jour globale a été effectuée sur les demandes d'habilitations "API Entreprise"
    Et que je me rends sur cette demande d'habilitation
    Alors il y a une modale contenant "mise à jour globale"

  Scénario: Je consulte une habilitation m'appartenant une seconde fois depuis une une mise à jour globale
    Quand j'ai 1 demande d'habilitation "API Entreprise" validée
    Et qu'une mise à jour globale a été effectuée sur les demandes d'habilitations "API Entreprise"
    Et que je me rends sur cette demande d'habilitation
    Et que je me rends sur cette demande d'habilitation
    Alors il n'y a pas de modale contenant "mise à jour globale"
