# Flaky Tests Analysis & Fix Plan

## Context

CI runs fail frequently due to flaky cucumber tests — typically 1 scenario out of ~500 fails per run. Over the last ~100 CI runs (~50 analyzed), 23 failed, with the majority being cucumber integration test failures. These are not deterministic bugs — the same tests pass on re-run or on other branches. The flakiness wastes CI time and blocks auto-merge to main.

## Identified Flaky Tests (from CI history, Feb 19–26 2026)

### Category 1: `instructor?` / method called on nil `current_user` (MOST COMMON — 5 occurrences)

**Failing scenarios:**
- `features/instructeurs/consultation_habilitation.feature:33` (2x)
- `features/consultation_demande.feature:22`
- `features/instructeurs/consultation_demande_lien_organisation.feature:12`
- `features/instructeurs/habilitations_france_connectees.feature:10`

**Error:** `undefined method 'instructor?' for nil (NoMethodError)`

**Root cause:** `current_user` in `features/support/sessions.rb:14-18` returns nil when `User.find_by(email: @current_user_email)` fails. This happens because:
- `@current_user_email` is nil (scenario missing a "je suis un X" step), OR
- The user record is not yet visible due to DB transaction isolation between the test thread and the Puma server thread (for `@javascript` scenarios using `:truncation` strategy)

**Affected code:**
- `features/step_definitions/authorization_requests_steps.rb:137` — `current_user.instructor?`
- `features/step_definitions/authorization_requests_steps.rb:506` — `current_user.instructor?`

**Fix:** Add safe navigation (`&.`) and a descriptive error when `current_user` is nil:

```ruby
# features/support/sessions.rb — add a guard method
def current_user!
  current_user || raise("current_user is nil — did you forget a 'je suis un(e) ...' step? (@current_user_email=#{@current_user_email.inspect})")
end
```

Then replace `current_user.instructor?` calls in `authorization_requests_steps.rb` with `current_user!.instructor?` to get clear error messages instead of cryptic NoMethodError.

### Category 2: `skip_data_protection_officer_informed_check_box?` on nil (2 occurrences)

**Failing scenarios:**
- `features/habilitations/api_particulier/soumission_multiples_etapes.feature:230`
- `features/habilitations/api_particulier/soumission_multiples_etapes.feature:323`

**Error:** `undefined method 'skip_data_protection_officer_informed_check_box?' for nil`

**Root cause:** At `authorization_requests_steps.rb:360`:
```ruby
authorization_request = @authorization_request || AuthorizationRequest.last
unless authorization_request.skip_data_protection_officer_informed_check_box?
```
`AuthorizationRequest.last` returns nil — the authorization request hasn't been committed to DB yet (truncation strategy timing issue with `@javascript` scenario), or it was cleaned up between steps.

**Fix:** Add a guard:
```ruby
authorization_request = @authorization_request || AuthorizationRequest.last
raise "No authorization request found" unless authorization_request
```

### Category 3: Capybara element not found — modal turbo-frame (1 occurrence)

**Failing scenario:**
- `features/gestion_des_documents.feature:75` — "Annulation d'une réouverture..."

**Error:** `Unable to find visible css "turbo-frame#main-modal-content"`

**Root cause:** In `features/step_definitions/web_steps.rb:40-44`:
```ruby
click_link_or_button label
within('turbo-frame#main-modal-content', wait: 5) do
  click_link_or_button label
end
```
The turbo-frame element exists in the DOM (it's in the layout) but its content hasn't loaded yet. The Cuprite driver `timeout: 2` (`spec/support/configure_javascript_driver.rb:47`) is too low — if the server response takes >2s under CI load, the frame content never arrives.

**Fix:**
1. Increase Cuprite `timeout` from `2` to `5` in `spec/support/configure_javascript_driver.rb:47`
2. Update the modal step to wait for content inside the frame:
```ruby
Quand('je clique sur {string} et confirme dans la modale') do |label|
  click_link_or_button label
  within('turbo-frame#main-modal-content', wait: 5) do
    find(:link_or_button, label, wait: 5)
    click_link_or_button label
  end
  expect(page).to have_no_css('turbo-frame#main-modal-content', wait: 5)
end
```

### Category 4: Capybara button not found — "Débuter ma demande" (1 occurrence)

**Failing scenario:**
- `features/habilitations/api_particulier/soumission_multiples_etapes.feature:230`

**Error:** `Unable to find link or button "Débuter ma demande"`

**Root cause:** Same Cuprite timeout issue. Page hasn't fully rendered under CI load. The `trigger('click')` approach in `web_steps.rb:33` bypasses visibility checks which can cause subsequent navigation to fail silently.

**Fix:** Increasing Cuprite `timeout` to 5 (same as Category 3) should resolve this.

### Category 5: Stats page content not found (3 occurrences — same branch)

**Failing scenario:**
- `features/stats_page.feature:12` — "Accès public à la page de statistiques" (3x on same branch)

**Error:** `expected to find text "Durée de remplissage d'une nouvelle demande"` — the text IS in the page HTML but preceded by "Chargement des statistiques…" loading overlay.

**Root cause:** The stats page loads data asynchronously via two sequential fetch calls (filters then data). The loading overlay hides content until JS completes. If the scenario runs with the JS driver, 5s wait may be insufficient. If without JS driver (`rack_test`), the Stimulus controller never executes so content stays behind the loading overlay. This was on a specific feature branch (`dp-1566-followup-stats-publiques`) and occurred 3 times consecutively — likely a real bug in that branch that was subsequently fixed (later runs on that branch pass).

**Verdict:** Likely NOT a flaky test — was a real bug on a feature branch. No fix needed now but worth monitoring.

### Category 6: `original_link_to` undefined method (1 occurrence)

**Error:** `undefined method 'original_link_to'` in `config/initializers/rails_pulse.rb:83`

**Root cause:** Race condition in Rails initialization — `rails_pulse.rb` monkey-patches `link_to` with `alias_method :original_link_to, :link_to`, but in rare CI timing conditions the alias isn't applied before the view renders. This affected 3 scenarios in a single run.

**Verdict:** Infrastructure/initialization issue, not a test issue. Low frequency (1 run out of ~50).

## Files to Modify

| File | Change |
|------|--------|
| `features/support/sessions.rb` | Add `current_user!` guard method |
| `features/step_definitions/authorization_requests_steps.rb` | Replace `current_user.instructor?` with `current_user!.instructor?` at lines 137 and 506; add nil guard at line 360 |
| `spec/support/configure_javascript_driver.rb` | Increase `timeout: 2` to `timeout: 5` |
| `features/step_definitions/web_steps.rb` | Add explicit wait for button inside modal frame |

## Verification

1. Run the full cucumber suite locally: `make e2e`
2. Run the specific flaky scenarios:
   - `make e2e features/instructeurs/consultation_habilitation.feature:33`
   - `make e2e features/habilitations/api_particulier/soumission_multiples_etapes.feature:230`
   - `make e2e features/gestion_des_documents.feature:75`
   - `make e2e features/consultation_demande.feature:22`
3. Run `make lint` to check code style
4. Push and monitor CI — the true test is whether flaky failures decrease across multiple CI runs
