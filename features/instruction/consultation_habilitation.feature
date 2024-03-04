# language: fr

Fonctionnalité: Instruction: consultation d'une habilitation
  Un instructeur peut consulter une habilitation et y voir des informations relatives aux entités

  Contexte:
    Sachant que je suis un instructeur "API Entreprise"
    Et que je me connecte

  Scénario: Je vois les informations sur l'organisation et le demandeur
    Quand je me rends sur une demande d'habilitation "API Entreprise" de l'organisation "Ville de Clamart" en brouillon
    Alors la page contient "Ville de Clamart"
    Et la page contient "1 PL MAURICE GUNSBOURG"
    Et la page contient "92140 CLAMART"
    Et la page contient "Dupont Jean"
    Et la page contient "Adjoint au Maire"

