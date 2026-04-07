---
shaping: true
---

# Shaping — Interface de gestion des droits pour les managers FD (DP-1613)

---

## Contexte

La gestion des droits est aujourd'hui admin-only (`/admin/utilisateurs-avec-roles`). Un manager FD doit passer par l'équipe DataPass pour tout changement : nouvel instructeur, départ d'agent, changement de rôle.

Ce shaping définit une interface dans l'espace instructeur permettant à un manager FD de gérer les droits de son FD en autonomie. Elle s'appuie sur DP-1612 (droits FD-level, format `fd:{slug}:{role}` stocké dans `users.roles`).

---

## Requirements (R)

| ID | Requirement | Status |
|----|-------------|--------|
| R0 | Un manager FD voit tous les utilisateurs ayant des droits sur son FD, qu'ils soient en FD-level (`fd:{slug}:{role}`) ou en definition-level (`{definition_id}:{role}`), hors admins DataPass | Core goal |
| R1 | Un manager FD peut ajouter ou modifier un droit en choisissant : email, portée (FD global = `fd:{slug}` ou une définition précise = `{definition_id}`), rôle (reporter/instructor/manager/developer) — vaut pour un nouvel utilisateur comme pour un utilisateur existant | Core goal |
| R2 | Un manager peut retirer tous les droits d'un user dans son périmètre : si manager FD, retire les droits FD-level et les droits definition-level de toutes les définitions de ses FDs ; si manager définition, retire uniquement les droits definition-level de ses définitions | Must-have |
| R3 | L'interface s'adapte à la portée du user : manager FD → voit ses N FDs ; manager définition → voit ses définitions uniquement ; admin → voit tous les FDs ; dans chaque cas il peut attribuer/modifier/retirer des droits dans son périmètre (sauf le rôle admin) | Must-have |
| R4 | Accessible via onglet « Droits » dans la nav de l'espace instructeur, visible managers et admins uniquement | Must-have |
| R5 | Un manager ne peut pas attribuer des droits supérieurs aux siens : seul un manager peut créer un autre manager ; instructor, reporter et developer sont des rôles inférieurs qu'un manager peut attribuer librement | Must-have |
| R6 | Un manager peut gérer uniquement les droits dans son périmètre : manager FD → droits de ses FDs (FD-level + definition-level) ; manager définition → droits scoped à ses définitions uniquement | Must-have |
| R7 | Un manager ne peut pas se retirer ses propres droits de manager (auto-révocation bloquée) | Nice-to-have |
| R8 | Les modifications sont tracées (AdminEvent) et notifient les admins DataPass | Must-have |
| R9 | L'interface expose la définition de chaque rôle : bouton « Définitions » sur la liste (ouvre une modale), et panneau contextuel à droite du formulaire | Must-have |
