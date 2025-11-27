# Inventory of Alerts in Authorization Views

This document lists all possible alerts that can be displayed in the two main views:
1. **Demande (Authorization Request)** - `authorization_request_forms/summary.html.erb`
2. **Habilitation (Authorization)** - `authorizations/show.html.erb`

**Note:** The "Résumé de la demande avant soumission" (Summary before submission) uses the same view file as "Demande" (`authorization_request_forms/summary.html.erb`) but with `@summary_before_submit = true` (when `@authorization_request.filling?`). It shares all alerts from sections A-J and adds section K.

---

## 1. DEMANDE (Authorization Request) View
**File:** `app/views/authorization_request_forms/summary.html.erb`

**Note:** This view file is also used for the "Résumé de la demande avant soumission" (Summary before submission). Sections A-J appear in both contexts. Section K appears only in the summary before submission view (when `@summary_before_submit = true`, i.e., when `@authorization_request.filling?`).

### A. Flash Messages (via `shared/_alerts.html.erb`)
These are displayed at the top via `render partial: 'shared/alerts'` in the form layout.

**Types:** `error`, `info`, `success`, `warning`

**Possible Flash Messages:**

#### Success Messages:
1. **Create/Update Success** (`authorization_request_forms.create.success` or `update.success`)
   - Title: "La demande d'habilitation %{name} a été sauvegardée avec succès"
   - Variant: Reopening success - "La demande de mise à jour de l'habilitation %{name} a été sauvegardée avec succès"

2. **Submit Success** (`authorization_request_forms.submit.success`)
   - Title: "La demande d'habilitation %{name} a été soumise avec succès"
   - Variant: Reopening submit success - "La demande de mise à jour de l'habilitation %{name} a été soumise avec succès"

#### Error Messages:
3. **Create/Update Error** (`authorization_request_forms.create.error` or `update.error`)
   - Title: "Une erreur est survenue lors de la sauvegarde de la demande d'habilitation"
   - Description: "Certains champs ci-dessous ne sont pas valides, merci d'effectuer les corrections nécessaires"
   - May include ActiveModel errors list
   - Variant: Reopening error - "Une erreur est survenue lors de la sauvegarde de la mise à jour de la demande d'habilitation"

4. **Submit Error** (`authorization_request_forms.submit.error`)
   - Title: "Une erreur est survenue lors de la soumission de la demande d'habilitation"
   - Description: "Certains champs ci-dessous ne sont pas valides, merci d'effectuer les corrections nécessaires"
   - May include ActiveModel errors list
   - Variant: Reopening submit error - "Une erreur est survenue lors de la soumission de la demande de mise à jour de l'habilitation"

### B. Current User Mentions Alert
**Partial:** `demandes_habilitations/_current_user_mentions_alert.html.erb`
- **Type:** `fr-alert fr-alert--info`
- **Condition:** `demande.only_in_contacts?(current_user)`
- **Message:** "Vous avez été référencé comme %{contact_types} dans cette habilitation."

### C. Changes Requested Alert
**Type:** `fr-alert fr-alert--warning`
**Condition:** `@authorization_request.changes_requested? && !displayed_on_a_public_page?`

**Variants:**
1. **Regular Changes Requested**
   - Title: "Votre demande d'habilitation nécessite des modifications avant d'être validée"
   - Description: "La raison évoquée par l'équipe d'instruction est la suivante :"
   - Includes blockquote with `@authorization_request.modification_request.reason`

2. **Reopening Changes Requested**
   - Title: "Votre demande de mise à jour nécessite des modifications avant d'être validée"
   - Description: "La raison évoquée par l'équipe d'instruction est la suivante :"
   - Includes blockquote with `@authorization_request.modification_request.reason`

### D. Refused Alert
**Type:** `fr-alert fr-alert--error`
**Condition:** `@authorization_request.refused? && !displayed_on_a_public_page?`

**Variants:**
1. **Regular Refused**
   - Title: "Votre demande d'habilitation a été refusée"
   - Description: "La raison évoquée par l'équipe d'instruction est la suivante :"
   - Includes blockquote with `@authorization_request.denial.reason`

2. **Reopening Refused**
   - Title: "Votre demande de mise à jour a été refusée"
   - Description: "La raison évoquée par l'équipe d'instruction est la suivante :"
   - Includes blockquote with `@authorization_request.denial.reason`

### E. Dirty from V1 Alert
**Type:** `fr-alert fr-alert--warning`
**Condition:** `@authorization_request.dirty_from_v1? && !displayed_on_a_public_page?`
- **Title:** "Cette demande d'habilitation ou habilitation est importée de la v1 de DataPass"
- **Description:** "Celle-ci présente des données incomplètes, manquantes ou corrompues. Par conséquent, certaines actions ne sont pas disponibles, telles que la réouverture ou le transfert. Si vous voulez effectuer des actions sur cette demande ou habilitation, merci de contacter le support à l'adresse datapass@api.gouv.fr"
- **Errors List:** If `@authorization_request.dirty_related_errors.any?`, displays:
  - "Les erreurs suivantes ont été rencontrées :"
  - List of errors

### F. Reopening Alerts (when @authorization is present)
**Condition:** `@authorization.present?`

#### F1. Update in Progress Alert
**Type:** `fr-alert fr-alert--info`
**Condition:** `@authorization.latest? && @authorization.request.reopening?`
- **Title:** "Une mise à jour de cette habilitation est en cours."
- **Message:** "Vous avez initié une mise à jour de cette habilitation. Vous pouvez y accéder en cliquant ici : Demande de mise à jour n°#{@authorization.request.id}"

#### F2. Old Version Alert
**Type:** `fr-alert fr-alert--warning`
**Condition:** `!@authorization.latest?`
- **Title:** "Attention, vous consultez une version ancienne de cette habilitation"
- **Message:** "Il existe une version plus récente de cette habilitation que vous pouvez consulter en cliquant ici: Habilitation n°#{@authorization_request.latest_authorization.id}"

### G. Access Callout
**Type:** `fr-callout`
**Condition:** `!displayed_on_a_public_page? && @authorization_request.access_link && @authorization_request.validated?`
- **Title:** "Votre accès est disponible"
- **Content:** "Votre accès **%{access_name}** a été créé, vous pouvez l'utiliser sur le lien ci-dessous."
- **Button:** "Utiliser mon accès" (links to `@authorization_request.access_link`)

### H. Reopening Callout
**Type:** `fr-callout fr-icon-information-line`
**Condition:** `@authorization_request.draft? && @authorization_request.reopening? && @authorization_request.applicant == current_user`
- **Title:** "Mise à jour de l'habilitation"
- **Text:** "Il s'agit d'une mise à jour d'une habilitation validée. Si celle-ci est rejetée, votre habilitation initiale sera toujours valide et les informations restaurées à la version initiale. Vous pouvez consulter à tout moment la dernière habilitation validée :"
- **Link:** "Consulter l'habilitation validée du %{authorization_created_at}"

### I. Unverified Organization Affiliation Alert
**Partial:** `demandes_habilitations/_organization_and_applicant.html.erb`
**Type:** `fr-alert fr-alert--warning`
**Condition:** `namespace?(:instruction) && demande.unverified_organization_affiliation? && !demande.finished?`
- **Message:** "Nous n'avons pas pu vérifier le lien entre le demandeur et le numéro de SIRET, assurez-vous que le demandeur est bien légitime pour faire cette demande. Plus d'informations sur la [vérification du lien entre le demandeur et l'organisation](link)"

### J. Bulk Update Modal
**Condition:** `@bulk_update.present?`
- **Title:** "Une mise à jour a été effectuée sur votre demande d'habilitation"
- **Description:** "Une mise à jour globale a été effectuée sur les habilitations %{authorization_definition_name} par l'équipe en charge de l'instruction de ces demandes. Le détail de cette mise à jour est expliquée ci-dessous :"

### K. Summary Title and Description (Résumé avant soumission uniquement)
**Condition:** `@authorization_request.draft? && !displayed_on_a_public_page? && !@authorization_request.reopening?`
**Note:** This section is only displayed when viewing the summary before submission (`@summary_before_submit = true` when `@authorization_request.filling?`)
- **Title:** "Récapitulatif de votre demande"
- **Description:** "Vous avez complété toutes les étapes de votre demande ! Vous pouvez à présent la soumettre à l'équipe d'instruction après avoir lu nos conditions générales d'utilisation."

---

## 2. HABILITATION (Authorization) View
**File:** `app/views/authorizations/show.html.erb`

### A. Current User Mentions Alert
**Partial:** `demandes_habilitations/_current_user_mentions_alert.html.erb`
- **Type:** `fr-alert fr-alert--info`
- **Condition:** `demande.only_in_contacts?(current_user)`
- **Message:** "Vous avez été référencé comme %{contact_types} dans cette habilitation."

### B. Authorization Alerts
**Partial:** `authorizations/_alerts.html.erb`

#### B1. Update in Progress Alert
**Type:** `fr-alert fr-alert--info`
**Condition:** `authorization.latest? && authorization.request.reopening?`
- **Title:** "Une mise à jour de cette habilitation est en cours."
- **Message:** "Vous avez initié une mise à jour de cette habilitation. Vous pouvez y accéder en cliquant ici : Demande de mise à jour n°#{authorization.request.id}"

#### B2. Old Version Alert
**Type:** `fr-alert fr-alert--warning`
**Condition:** `!authorization.latest?`
- **Title:** "Attention, vous consultez une version ancienne de cette habilitation"
- **Message:** "Il existe une version plus récente de cette habilitation que vous pouvez consulter en cliquant ici: Habilitation n°#{authorization_request.latest_authorization.id}"

### C. Access Callout
**Partial:** `authorizations/_access_callout.html.erb`
**Type:** `fr-callout`
**Condition:** `!displayed_on_a_public_page? && authorization.request.access_link && authorization.request.validated?`
- **Title:** "Votre accès est disponible"
- **Content:** "Votre accès **%{access_name}** a été créé, vous pouvez l'utiliser sur le lien ci-dessous."
- **Button:** "Utiliser mon accès" (links to `authorization_request.access_link`)

### D. Unverified Organization Affiliation Alert
**Partial:** `demandes_habilitations/_organization_and_applicant.html.erb`
**Type:** `fr-alert fr-alert--warning`
**Condition:** `namespace?(:instruction) && demande.unverified_organization_affiliation? && !demande.finished?`
- **Message:** "Nous n'avons pas pu vérifier le lien entre le demandeur et le numéro de SIRET, assurez-vous que le demandeur est bien légitime pour faire cette demande. Plus d'informations sur la [vérification du lien entre le demandeur et l'organisation](link)"

---

## Summary by Alert Type

### Info Alerts (fr-alert--info):
1. Current User Mentions Alert
2. Update in Progress Alert (reopening)
3. Flash info messages

### Warning Alerts (fr-alert--warning):
1. Changes Requested Alert
2. Dirty from V1 Alert
3. Old Version Alert (reopening)
4. Unverified Organization Affiliation Alert
5. Flash warning messages

### Error Alerts (fr-alert--error):
1. Refused Alert
2. Flash error messages

### Success Alerts (fr-alert--success):
1. Flash success messages (create, update, submit)

### Callouts (fr-callout):
1. Access Callout
2. Reopening Callout

### Modals:
1. Bulk Update Modal

---

## Notes

- All flash messages are rendered via `shared/_alerts.html.erb` partial
- Flash messages can be of type: `error`, `info`, `success`, `warning`
- Some alerts are conditional based on:
  - Authorization request state (draft, changes_requested, refused, validated, etc.)
  - Whether it's a reopening
  - Whether user is on a public page
  - Whether user is in instruction namespace
  - Whether authorization is latest version
- The same partials are reused across different views
- Some alerts have variants for regular vs reopening scenarios

