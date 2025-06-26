# language: fr

Fonctionnalité: Instruction: consultation d'une habilitation
  Un rapporteur peut consulter une habilitation et y voir des informations relatives aux entités,
  il ne peut cependant pas effectuer de modération sur les demandes.

  Contexte:
    Sachant que je suis un rapporteur "API Entreprise"
    Et que je me connecte

  Scénario: Je vois les informations sur l'organisation et le demandeur
    Quand je me rends sur une demande d'habilitation "API Entreprise" de l'organisation "Ville de Clamart" en brouillon
    Alors la page contient "COMMUNE DE CLAMART"
    Et la page contient "1 PL MAURICE GUNSBOURG"
    Et la page contient "92140 CLAMART"
    Et la page contient "DUPONT Jean"
    Et la page contient "Adjoint au Maire"

  Scénario: Je ne peux effectuer aucune action sur les demandes
    Quand je me rends sur une demande d'habilitation "API Entreprise" à modérer
    Alors il n'y a pas de bouton "Valider"
    Et il n'y a pas de bouton "Refuser"
    Et il n'y a pas de bouton "Demander des modifications"
    Et il n'y a pas de bouton "Supprimer la demande"
    Et il n'y a pas de bouton "Révoquer"
    Et la page ne contient pas "Instruire la demande"
