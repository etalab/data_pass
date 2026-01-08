# Plan: Rationnalisation des alertes sur les demandes/habilitations

Issue principale: [DP-1311](https://linear.app/pole-api/issue/DP-1311)

## Contexte

Problème: Les demandeurs oublient de soumettre leurs drafts, notamment lors de demandes de modification. Il faut rendre l'action "soumettre" plus évidente en rationnalisant les alertes.

Principe directeur:
- **Alertes techniques** (sauvegarde/soumission impossible) -> composant alerte standard
- **Alertes métier** (demande de modification, refus) -> bandeau d'information importante (custom, basé sur Figma)

## 1. Création des composants d'alertes

### 1.1 TinyAlertComponent

Alerte compacte pour messages mineurs (sauvegarde réussie, etc.)

**Props:**
- `type`: `:success | :info | :warning | :error`
- `message`: `String`
- `dismissible`: `Boolean` (default: true)

**Fichiers:**
- `app/components/tiny_alert_component.rb`
- `app/components/tiny_alert_component.html.erb`
- `spec/components/tiny_alert_component_spec.rb`
- `spec/components/previews/tiny_alert_component_preview.rb`

**Design:** cf. `claude/demande-alerts/tiny-alert.png`

**Comportement:** Static, pas de disparition automatique. On garde le bouton de fermeture.

### 1.2 StandardAlertComponent

Alerte DSFR classique (reprend le code de `app/views/shared/_alerts.html.erb`)

**Props:**
- `type`: `:success | :info | :warning | :error`
- `title`: `String`
- `message`: `String` (peut contenir une liste d'erreurs)
- `close_button`: `Boolean` (default: true)

**Fichiers:**
- `app/components/standard_alert_component.rb`
- `app/components/standard_alert_component.html.erb`
- `spec/components/standard_alert_component_spec.rb`
- `spec/components/previews/standard_alert_component_preview.rb`

### 1.3 AuthorizationRequestFromInstructorBannerComponent

Bandeau custom (basé sur design Figma) pour messages importants de l'instructeur (demande de modification, refus) et pour le bandeau synthèse (DP-1327).

**Props:**
- `authorization_request`: `AuthorizationRequest`
- `full_width`: `Boolean` (default: true)

**Logique interne:**
- Si `changes_requested?` -> affiche message de demande de modification avec raison
- Si `refused?` -> affiche message de refus avec raison
- Gère les cas `reopening?` (mise à jour) avec messages adaptés
- Si `draft?` (sur page synthèse) -> affiche bandeau incitatif à soumettre

**Fichiers:**
- `app/components/authorization_request_from_instructor_banner_component.rb`
- `app/components/authorization_request_from_instructor_banner_component.html.erb`
- `spec/components/authorization_request_from_instructor_banner_component_spec.rb`
- `spec/components/previews/authorization_request_from_instructor_banner_component_preview.rb`

**Design:** cf. `claude/demande-alerts/authorization-request-from-instructor-banner.png`

## 2. Composants agrégateurs par contexte

### 2.1 Demande::UserAlertsComponent

Alertes pour le demandeur sur une demande d'habilitation.

**Props:**
- `authorization_request`: `AuthorizationRequest`

**Alertes à gérer:**

| Condition | Type | Issue |
|-----------|------|-------|
| Erreur sauvegarde (flash) | StandardAlert error | DP-1344 |
| Erreur soumission (flash) | StandardAlert error | DP-1345 |
| Demande de modification (`changes_requested?`) | Banner warning | DP-1347 |
| Demande de modification en reopening (`changes_requested? && reopening?`) | Banner warning | DP-1348 |
| Refus (`refused?`) | Banner error | DP-1349 |
| Refus en reopening (`refused? && reopening?`) | Banner error | DP-1350 |
| Import V1 dirty (`dirty_from_v1?`) | StandardAlert warning | DP-1351 |
| Draft sur synthèse | Banner info (incitatif soumettre) | DP-1327 |

**Alertes à SUPPRIMER:**
- Alerte succès lors de toutes les sauvegardes (DP-1360) - remplacée par TinyAlert
- Bandeau contact référencé -> déplacer dans header (DP-1346)

**Fichiers:**
- `app/components/demande/user_alerts_component.rb`
- `app/components/demande/user_alerts_component.html.erb`
- `spec/components/demande/user_alerts_component_spec.rb`
- `spec/components/previews/demande/user_alerts_component_preview.rb`

### 2.2 Demande::InstructorAlertsComponent

Alertes pour l'instructeur sur une demande.

**Props:**
- `authorization_request`: `AuthorizationRequest`

**Alertes à gérer:**
- Bandeau mise à jour en cours (si `reopening?`) - cf. `_reopening_callout.html.erb`

**Alertes à SUPPRIMER:**
- Bandeau mise à jour de l'habilitation (DP-1338) - redondant avec d'autres infos

**Fichiers:**
- `app/components/demande/instructor_alerts_component.rb`
- `app/components/demande/instructor_alerts_component.html.erb`
- `spec/components/demande/instructor_alerts_component_spec.rb`
- `spec/components/previews/demande/instructor_alerts_component_preview.rb`

### 2.3 Habilitation::UserAlertsComponent

Alertes pour le demandeur sur une habilitation validée.

**Props:**
- `authorization`: `Authorization`

**Alertes à gérer:**

| Condition | Type | Issue |
|-----------|------|-------|
| Mise à jour en cours (`authorization.request.reopening?`) | Banner info | DP-1352 |

**Alertes à SUPPRIMER:**
- Alerte ancienne habilitation (`!authorization.latest?`) -> info dans header (DP-1353)
- Bandeau contact référencé -> déplacer dans header (DP-1346)

**Fichiers:**
- `app/components/habilitation/user_alerts_component.rb`
- `app/components/habilitation/user_alerts_component.html.erb`
- `spec/components/habilitation/user_alerts_component_spec.rb`
- `spec/components/previews/habilitation/user_alerts_component_preview.rb`

**Note:** Pas de `Habilitation::InstructorAlertsComponent` car les instructeurs n'ont pas de vue show pour les habilitations (seulement une liste dans `instruction/authorizations/index.html.erb`).

## 3. Modifications des vues existantes

### 3.1 Vue demandeur - Demande (`authorization_request_forms/summary.html.erb`)

**Remplacer:**
```erb
<%= render partial: 'demandes_habilitations/current_user_mentions_alert' %>
<!-- alertes changes_requested, refused, dirty_from_v1 -->
<!-- titre + description synthèse -->
```

**Par:**
```erb
<%= render Demande::UserAlertsComponent.new(authorization_request: @authorization_request) %>
```

### 3.2 Vue demandeur - Habilitation (`authorizations/show.html.erb`)

Cette vue est utilisée uniquement par le demandeur (via `AuthorizationsController#show`).

**Remplacer:**
```erb
<%= render partial: 'demandes_habilitations/current_user_mentions_alert' %>
<%= render partial: 'authorizations/alerts' %>
```

**Par:**
```erb
<%= render Habilitation::UserAlertsComponent.new(authorization: authorization) %>
```

### 3.3 Vue instructeur - Demande (`instruction/authorization_requests/show.html.erb`)

**Remplacer:**
```erb
<%= render partial: "authorization_requests/shared/reopening_callout", locals: { type: :instructor } if @authorization_request.reopening? %>
```

**Par:**
```erb
<%= render Demande::InstructorAlertsComponent.new(authorization_request: @authorization_request) %>
```

## 4. Modifications des messages flash

### 4.1 Sauvegarde réussie (DP-1343, DP-1360)

Remplacer l'alerte standard par TinyAlert pour toutes les sauvegardes.

**Controller:** `AuthorizationRequestFormsController`
- Actions: `create`, `update`
- Nouveau message: "Demande sauvegardée"
- Type: TinyAlert success

**Comportement:** Le TinyAlert sera affiché via un mécanisme de flash spécifique (ex: `flash[:tiny_success]`).

### 4.2 Erreurs de validation (DP-1344, DP-1345)

**Messages à modifier dans `config/locales/fr.yml`:**

```yaml
authorization_request_forms:
  update:
    error:
      title: "Nous n'avons pas pu sauvegarder votre demande"
      description: "Certains champs de votre demande ne sont pas valides, merci de les corriger"
  submit:
    error:
      title: "Nous n'avons pas pu transmettre votre demande"
      description: "Certains champs de votre demande ne sont pas valides, merci de les corriger"
```

## 5. Modifications du header

### 5.1 Déplacer info contact référencé (DP-1346)

Modifier `AuthorizationHeaderComponent` pour afficher "Vous êtes référencé comme X" dans le header.

### 5.2 Afficher info habilitation obsolète (DP-1353)

Modifier `AuthorizationHeaderComponent` pour afficher "Cette habilitation est obsolète, remplacée par [lien]" si `!authorization.latest?`

## 6. Hiérarchie des boutons (DP-1359)

**Note:** Hors scope alertes, mais mentionné dans l'issue parent.

Sur les pages demande:
- Bouton "Suivant" = primaire
- Bouton "Enregistrer" = secondaire
- Bouton "Supprimer" = tertiaire

## 7. Ordre d'implémentation

1. **Composants de base** (TDD)
   - TinyAlertComponent + tests + preview
   - StandardAlertComponent + tests + preview
   - AuthorizationRequestFromInstructorBannerComponent + tests + preview

2. **Composants agrégateurs** (TDD)
   - Demande::UserAlertsComponent + tests + preview
   - Demande::InstructorAlertsComponent + tests + preview
   - Habilitation::UserAlertsComponent + tests + preview

3. **Intégration dans les vues**
   - Modifier `authorization_request_forms/summary.html.erb`
   - Modifier `authorizations/show.html.erb`
   - Modifier `instruction/authorization_requests/show.html.erb`

4. **Modifications flash/messages**
   - Adapter les controllers pour TinyAlert
   - Mettre à jour les traductions

5. **Modifications header**
   - AuthorizationHeaderComponent: contact référencé
   - AuthorizationHeaderComponent: habilitation obsolète

6. **Nettoyage**
   - Supprimer les partials inutilisés (`_current_user_mentions_alert`, `_alerts`, etc.)
   - Supprimer le code mort

7. **Tests E2E**
   - Vérifier scénarios cucumber existants
   - Ajouter tests si nécessaire

8. **Documentation**
   - Créer `docs/alerts.md` avec la documentation des composants

## 8. Stories Lookbook

Pour chaque composant preview, créer des stories avec les variations:

**TinyAlertComponent:**
- Types: success, info, warning, error
- Avec/sans bouton fermer

**StandardAlertComponent:**
- Types: success, info, warning, error
- Avec titre + description
- Avec liste d'erreurs

**AuthorizationRequestFromInstructorBannerComponent:**
- Demande de modification (standard)
- Demande de modification (reopening)
- Refus (standard)
- Refus (reopening)
- Bandeau synthèse (draft, incitatif)
- Full width vs contained

**Demande::UserAlertsComponent:**
- Draft sur synthèse (bandeau incitatif)
- Changes requested
- Changes requested (reopening)
- Refused
- Refused (reopening)
- Dirty from V1
- Combinaisons multiples

**Demande::InstructorAlertsComponent:**
- Sans alerte (demande standard)
- Reopening en cours

**Habilitation::UserAlertsComponent:**
- Standard (pas d'alerte)
- Mise à jour en cours
