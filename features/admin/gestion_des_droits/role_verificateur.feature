# language: fr

Fonctionnalité: Admin — Gestion des droits — rôle de vérificateur du registre wallet
  En tant qu’administrateur, je désigne les personnes qui vérifient les
  demandes d’enregistrement au registre wallet.

  Contexte:
    Sachant que je suis un administrateur
    Et que je me connecte

  Scénario: Je donne le rôle de vérificateur
    Quand il y a l'utilisateur "verif@gouv.fr" sans rôle
    Et que je me rends sur la page d'ajout de droits
    Et que je remplis "Email de l’utilisateur" avec "verif@gouv.fr"
    Et que je sélectionne "Registre des parties utilisatrices du wallet" pour "Portée des droits"
    Et que je sélectionne "Vérificateur" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors il y a un message de succès contenant "mis à jour"
    Et l'utilisateur "verif@gouv.fr" a les rôles "dinum:registre_wallet:verifier"
    Et le journal des actions admin trace un changement de droits par moi sur "verif@gouv.fr"
    Et le tableau des utilisateurs contient le badge "Vérificateur"

  Scénario: Je ne peux pas donner le rôle de vérificateur sur un autre service
    Quand il y a l'utilisateur "verif@gouv.fr" sans rôle
    Et que je me rends sur la page d'ajout de droits
    Et que je remplis "Email de l’utilisateur" avec "verif@gouv.fr"
    Et que je sélectionne "API Entreprise" pour "Portée des droits"
    Et que je sélectionne "Vérificateur" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors la page contient "« Vérificateur » n’existe que sur le registre wallet"

  Scénario: Une adresse sans compte ne reçoit aucun rôle
    Quand je me rends sur la page d'ajout de droits
    Et que je remplis "Email de l’utilisateur" avec "inconnu@gouv.fr"
    Et que je sélectionne "Registre des parties utilisatrices du wallet" pour "Portée des droits"
    Et que je sélectionne "Vérificateur" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors la page contient le message d’adresse sans compte
    Et aucun compte n’existe pour "inconnu@gouv.fr"
