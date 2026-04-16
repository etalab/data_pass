# language: fr

Fonctionnalité: Bannissement des utilisateurs
  En tant qu'administrateur
  Je veux pouvoir bannir un utilisateur
  Pour bloquer l'accès à DataPass d'un compte compromis

  Contexte:
    Étant donné que je suis un administrateur
    Et qu'il existe un utilisateur ayant l'email "user@example.com"
    Et que je me connecte

  Scénario: Un administrateur peut bannir un utilisateur
    Quand je me rends sur le module "Bannissements" de l'espace administrateur
    Et que je clique sur "Bannir un utilisateur"
    Et que je remplis "Email" avec "user@example.com"
    Et que je remplis "Raison du ban" avec "Compte compromis signalé par le CSIRT"
    Et que je clique sur "Bannir"

    Alors il y a un message de succès contenant "user@example.com"
    Et la page contient "user@example.com"

  Scénario: Un administrateur peut lever le ban d'un utilisateur
    Étant donné que l'utilisateur "user@example.com" est banni
    Quand je me rends sur le module "Bannissements" de l'espace administrateur
    Et que je clique sur "Lever le ban"
    Et que je clique sur "Confirmer"

    Alors il y a un message de succès contenant "user@example.com"
    Et la page contient "Aucun utilisateur banni"

  Scénario: Un administrateur ne peut pas bannir un utilisateur inexistant
    Quand je me rends sur le module "Bannissements" de l'espace administrateur
    Et que je clique sur "Bannir un utilisateur"
    Et que je remplis "Email" avec "inconnu@example.com"
    Et que je remplis "Raison du ban" avec "Test"
    Et que je clique sur "Bannir"

    Alors il y a un message d'erreur contenant "Aucun utilisateur trouvé avec cet email"
