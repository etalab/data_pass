# Comportement du Tableau de Bord - Vue Utilisateur

Ce document décrit précisément quelles demandes d'habilitations et habilitations sont affichées sur le tableau de bord pour chaque type d'utilisateur et dans chaque contexte.

## Table des matières

1. [Utilisateurs avec organisation vérifiée](#utilisateurs-avec-organisation-vérifiée)
2. [Utilisateurs avec organisation non vérifiée](#utilisateurs-avec-organisation-non-vérifiée)
3. [Filtres disponibles](#filtres-disponibles)
4. [Seuil d'affichage des filtres](#seuil-daffichage-des-filtres)
5. [Exemples concrets](#exemples-concrets)

---

## Utilisateurs avec organisation vérifiée

### Sans filtre appliqué

Lorsqu'un utilisateur avec une **organisation vérifiée** consulte son tableau de bord sans appliquer de filtre, il voit :

✅ **Affichées :**
- Toutes ses propres demandes/habilitations dans l'organisation courante
- Toutes les demandes/habilitations des autres membres de l'organisation courante
- Les demandes/habilitations d'autres organisations où l'utilisateur est mentionné comme contact (ex: contact métier, contact technique, etc.)

❌ **Non affichées :**
- Ses propres demandes/habilitations dans d'autres organisations où il est membre mais qui ne sont pas l'organisation courante

**Exemple :**

Alice travaille pour deux organisations :
- Organisation A (Ville de Paris) - organisation courante ✅
- Organisation B (Ville de Lyon) - autre organisation où Alice est aussi membre

Alice a créé :
- 5 demandes dans l'organisation A
- 3 demandes dans l'organisation B

Son collègue Bob (également dans l'organisation A) a créé :
- 2 demandes dans l'organisation A

Charles (dans l'organisation C) a créé :
- 1 demande où Alice est mentionnée comme contact métier

**Sur le tableau de bord, Alice verra :**
- ✅ 5 demandes (ses demandes dans l'organisation A)
- ✅ 2 demandes (les demandes de Bob dans l'organisation A)
- ✅ 1 demande (la demande de Charles où elle est contact)
- ❌ 3 demandes dans l'organisation B ne sont PAS affichées

**Total affiché : 8 demandes**

---

### Avec filtre "Demandeur" (applicant)

Affiche uniquement les demandes/habilitations où l'utilisateur est le demandeur (applicant) **dans l'organisation courante**.

**Reprise de l'exemple précédent :**

Quand Alice applique le filtre "Demandeur" :
- ✅ 5 demandes (ses demandes dans l'organisation A)
- ❌ 2 demandes de Bob
- ❌ 1 demande de Charles
- ❌ 3 demandes dans l'organisation B

**Total affiché : 5 demandes**

---

### Avec filtre "Toutes les demandes de l'organisation"

Affiche toutes les demandes/habilitations de l'organisation courante, quel que soit le demandeur.

**Reprise de l'exemple précédent :**

Quand Alice applique le filtre "Toutes les demandes de l'organisation" :
- ✅ 5 demandes (ses demandes dans l'organisation A)
- ✅ 2 demandes (les demandes de Bob dans l'organisation A)
- ❌ 1 demande de Charles (autre organisation)
- ❌ 3 demandes dans l'organisation B

**Total affiché : 7 demandes**

---

### Avec filtre "Je suis mentionné en contact"

Affiche uniquement les demandes/habilitations où l'utilisateur est mentionné comme contact (contact métier, contact technique, responsable traitement, DPO, etc.), **quelle que soit l'organisation**.

**Reprise de l'exemple précédent :**

Quand Alice applique le filtre "Je suis mentionné en contact" :
- ❌ 5 demandes (ses propres demandes)
- ❌ 2 demandes de Bob
- ✅ 1 demande de Charles (où Alice est contact métier)
- ❌ 3 demandes dans l'organisation B (Alice est demandeur, pas contact)

**Total affiché : 1 demande**

---

## Utilisateurs avec organisation non vérifiée

### Sans filtre appliqué

Lorsqu'un utilisateur avec une **organisation non vérifiée** consulte son tableau de bord sans appliquer de filtre, il voit :

✅ **Affichées :**
- Uniquement ses propres demandes/habilitations (quelle que soit l'organisation)
- Les demandes/habilitations où il est mentionné comme contact

❌ **Non affichées :**
- Les demandes/habilitations des autres membres de son organisation

**Exemple :**

David a une organisation non vérifiée (Ville de Marseille).

David a créé :
- 4 demandes

Son collègue Émilie (également dans l'organisation de David) a créé :
- 3 demandes

François (autre organisation) a créé :
- 1 demande où David est mentionné comme contact technique

**Sur le tableau de bord, David verra :**
- ✅ 4 demandes (ses propres demandes)
- ❌ 3 demandes d'Émilie (non affichées car organisation non vérifiée)
- ✅ 1 demande de François (où David est contact)

**Total affiché : 5 demandes**

---

### Filtres disponibles pour utilisateur non vérifié

Pour les utilisateurs avec organisation non vérifiée, seuls **2 filtres** sont disponibles :

1. ✅ **"Demandeur"** : Affiche uniquement ses propres demandes
2. ✅ **"Je suis mentionné en contact"** : Affiche les demandes où il est contact

Le filtre **"Toutes les demandes de l'organisation"** est :
- ❌ **Masqué dans l'interface** (l'option n'apparaît pas dans le sélecteur)
- 🔒 **Protégé côté backend** : Si l'utilisateur force le paramètre via URL, il obtient 0 résultat

---

## Filtres disponibles

### Vue complète des filtres

| Filtre | Utilisateur vérifié | Utilisateur non vérifié | Description |
|--------|---------------------|-------------------------|-------------|
| **Demandeur** | ✅ Disponible | ✅ Disponible | Demandes/habilitations où l'utilisateur est le demandeur dans l'organisation courante |
| **Je suis mentionné en contact** | ✅ Disponible | ✅ Disponible | Demandes/habilitations où l'utilisateur est mentionné comme contact (toute organisation) |
| **Toutes les demandes de l'organisation** | ✅ Disponible | ❌ **Masqué** | Toutes les demandes/habilitations de l'organisation courante |

---

## Seuil d'affichage des filtres

Les filtres de recherche ne sont affichés que si l'utilisateur a **10 demandes/habilitations ou plus** dans la catégorie concernée (selon les états affichés).

### Règle de calcul

Le seuil est calculé sur les états affichés dans l'onglet :

#### Onglet "Demandes"
États comptés : `draft`, `submitted`, `changes_requested`, `refused`, `revoked`, `validated`

#### Onglet "Habilitations"
États comptés : `active`, `revoked`, `obsolete`

### Exemples

**Exemple 1 : Affichage des filtres**

Alice a :
- 12 demandes au total

→ **Filtres affichés** ✅ (seuil de 10 dépassé)

**Exemple 2 : Masquage des filtres**

Bob a :
- 9 demandes au total

→ **Filtres masqués** ❌ (seuil de 10 non atteint)

**Exemple 3 : Indépendance des onglets**

Caroline a :
- 15 demandes
- 5 habilitations

→ **Filtres affichés sur l'onglet "Demandes"** ✅
→ **Filtres masqués sur l'onglet "Habilitations"** ❌

---

## Exemples concrets

### Scénario 1 : Multi-organisations avec utilisateur vérifié

**Contexte :**
- Alice est membre de 3 organisations :
  - Org A (Ville de Paris) - organisation courante ✅
  - Org B (Ville de Lyon)
  - Org C (DINUM)
- Toutes ses organisations sont vérifiées

**Demandes créées :**
- Alice : 8 demandes dans Org A, 5 demandes dans Org B, 2 demandes dans Org C
- Bernard (Org A) : 3 demandes dans Org A
- Chloé (Org B) : 1 demande dans Org B où Alice est contact métier
- Denis (Org C) : 1 demande dans Org C où Alice est contact technique

**Affichage sans filtre :**
```
✅ 8 demandes d'Alice dans Org A (org courante)
✅ 3 demandes de Bernard dans Org A (org courante)
✅ 1 demande de Chloé (Alice est contact)
✅ 1 demande de Denis (Alice est contact)
❌ 5 demandes d'Alice dans Org B (pas org courante)
❌ 2 demandes d'Alice dans Org C (pas org courante)

Total : 13 demandes affichées
```

**Avec filtre "Demandeur" :**
```
✅ 8 demandes d'Alice dans Org A uniquement

Total : 8 demandes affichées
```

**Avec filtre "Toutes les demandes de l'organisation" :**
```
✅ 8 demandes d'Alice dans Org A
✅ 3 demandes de Bernard dans Org A

Total : 11 demandes affichées
```

**Avec filtre "Je suis mentionné en contact" :**
```
✅ 1 demande de Chloé (Alice est contact)
✅ 1 demande de Denis (Alice est contact)

Total : 2 demandes affichées
```

---

### Scénario 2 : Organisation non vérifiée

**Contexte :**
- Éric a une organisation non vérifiée (Association locale)
- Éric est le seul membre avec accès à DataPass

**Demandes créées :**
- Éric : 6 demandes
- Fabien (autre organisation) : 1 demande où Éric est contact métier

**Affichage sans filtre :**
```
✅ 6 demandes d'Éric
✅ 1 demande de Fabien (Éric est contact)

Total : 7 demandes affichées
```

**Filtres disponibles :**
```
✅ "Demandeur" : disponible
✅ "Je suis mentionné en contact" : disponible
❌ "Toutes les demandes de l'organisation" : MASQUÉ (organisation non vérifiée)
```

**Si Éric force le paramètre organisation via URL :**
```
→ Aucun résultat (protection backend)
→ Pas de message d'erreur affiché
```

---

### Scénario 3 : Changement d'organisation courante

**Contexte :**
- Gabrielle est membre de 2 organisations vérifiées :
  - Org A (Ministère X) - organisation courante initialement
  - Org B (Ministère Y)

**Demandes créées :**
- Gabrielle : 10 demandes dans Org A, 5 demandes dans Org B

**Étape 1 : Organisation courante = Org A**
```
✅ 10 demandes dans Org A

Total : 10 demandes affichées
```

**Étape 2 : Gabrielle change d'organisation courante → Org B**
```
❌ 10 demandes dans Org A ne sont plus affichées
✅ 5 demandes dans Org B sont maintenant affichées

Total : 5 demandes affichées
```

---

## Notes techniques

### Architecture

La logique d'affichage est implémentée dans plusieurs composants :

1. **Policy Scope** (Pundit) : Détermine les demandes accessibles selon l'organisation
2. **Service `DemandesHabilitationsSearchEngineBuilder`** : Construit la requête avec les filtres
3. **Query `DemandesHabilitationsViewableByUser`** : Calcule le nombre de demandes pour le seuil
4. **Query `AuthorizationAndRequestsMentionsQuery`** : Trouve les demandes où l'utilisateur est mentionné
5. **Facade `AbstractDashboardFacade`** : Détermine si les filtres doivent être affichés
6. **Vue `_search_form.html.erb`** : Affiche conditionnellement l'option "Organisation"

### Protection multi-niveaux

La protection contre l'accès non autorisé au filtre "Organisation" se fait à deux niveaux :

**Niveau 1 - Interface (UX) :**
- Le filtre n'est pas affiché pour les utilisateurs non vérifiés
- Fichier : `app/views/dashboard/_search_form.html.erb`

**Niveau 2 - Backend (Sécurité) :**
- Si un utilisateur non vérifié force le paramètre, il reçoit 0 résultat
- Fichier : `app/services/demandes_habilitations_search_engine_builder.rb:50`
- Code : `return base_items.none unless user.current_organization_verified?`

### Performance

Pour optimiser les performances, la requête pour exclure les demandes de l'utilisateur comme demandeur utilise :

- **Memoization** : Évite de répéter la même requête SQL dans la même requête HTTP
- **Subquery avec pluck(:id)** : Contourne les incompatibilités structurelles ActiveRecord avec `.or()`
- Fichier : `app/queries/authorization_and_requests_mentions_query.rb`

---

## Changelog

- **2025-01-XX** : Correction de la régression multi-organisations (DAT-1284)
- **2025-01-XX** : Ajout de la protection contre le forçage du filtre organisation
- **2025-01-XX** : Création de cette documentation