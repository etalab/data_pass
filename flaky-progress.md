# Flaky Tests Fix — Progress Log

## 2026-02-26

### Task 1: Add `current_user!` guard method — SUCCESS
- Added `current_user!` method to `features/support/sessions.rb` (after line 18)
- Raises descriptive error: "current_user is nil — did you forget a 'je suis un(e) ...' step?"
- Rubocop: pass

### Task 2: Replace `current_user.instructor?` with `current_user!.instructor?` — SUCCESS
- Line 137: replaced in "je me rends sur cette demande d'habilitation" step
- Line 506: replaced in "je me rends sur une demande d'habilitation" step
- Rubocop: pass

### Task 3: Add nil guard for authorization_request at line 360 — SUCCESS
- Added `raise 'No authorization request found' unless authorization_request` before `.skip_data_protection_officer_informed_check_box?`
- Rubocop: pass

### Task 4: Increase Cuprite timeout from 2 to 5 — SUCCESS
- Changed `timeout: 2` to `timeout: 5` in `spec/support/configure_javascript_driver.rb:47`
- Note: `default_max_wait_time` was already 5 (line 55), so the Cuprite timeout now matches
- Rubocop: pass

### Task 5: Add explicit wait for button inside modal frame — SUCCESS
- Added `find(:link_or_button, label, wait: 5)` before `click_link_or_button` inside the modal `within` block
- This ensures turbo-frame content is fully loaded before clicking
- Rubocop: pass

### Task 6: Lint — SUCCESS
- All 4 files pass rubocop with no offenses

### Not addressed (per plan):
- Category 5 (stats page): Likely a real bug on a feature branch, not flaky
- Category 6 (`original_link_to`): Infrastructure/initialization issue, low frequency (1/50 runs)

### Task 7: Fix "il y a un titre contenant" step (NEW FLAKY) — SUCCESS
- `web_steps.rb:9-12`: `page.all('h1, ...') + any?` doesn't use Capybara's waiting mechanism
- Replaced with `expect(page).to have_css('h1, p.fr-h2, h2, table caption', text:)` which retries until timeout
- Also fixed the negative version (`il n'y a pas de titre contenant`) the same way
- This step is used 121 times across 36 feature files — high impact fix
- Failing scenario: `features/acces_espaces_en_fonction_des_roles.feature:30` (reporter accessing admin page, redirected to dashboard)
- Rubocop: pass

### CI Run #1 (PR #1404) — ALL GREEN
- Build: pass
- RSpec: pass
- Cucumber: pass (all ~500 scenarios)
- All linting: pass
- Run URL: https://github.com/etalab/data_pass/actions/runs/22449154359

### CI Run #2 (PR #1404, re-run) — FAILED (1/501)
- Cucumber: `features/acces_espaces_en_fonction_des_roles.feature:30` failed
- Root cause: `page.all` + manual check doesn't wait — new Category 7 flaky
- Fixed in Task 7 above

### CI Run #3 (PR #1404, re-run after Task 7 push) — FAILED (2/501, seed 15276)

**Failure A: `features/tableau_de_bord.feature:71`** — "Le filtre est spécifique à chaque onglet"
- Error: `expected to find text "Rechercher dans toutes les demandes"` but page shows homepage with "S'identifier avec ProConnect"
- The user was NOT logged in despite Contexte having `je suis un demandeur` + `je me connecte`
- Non-JS test (rack_test, transaction strategy)
- Root cause hypothesis: session loss — user's login session was somehow invalidated between login and dashboard visit. Possibly related to DB state from a prior scenario affecting the user lookup or session store.

**Failure B: `features/instructeurs/affichage_messages_historique.feature:22`** — "Je clique sur voir le message"
- Error: `Ambiguous match, found 11 elements matching visible link or button "Consulter"` at `web_steps.rb:29`
- The Contexte creates only 1 authorization request, but 11 "Consulter" buttons are visible
- `@javascript` scenario using truncation strategy
- Root cause hypothesis: DB records leaked from a prior scenario — DatabaseCleaner truncation didn't complete before this scenario started. 10 extra authorization requests left over.

**Analysis of both failures:**
- Both happened in the same run (seed 15276) — likely a test ordering issue
- Failure B is clearly a DB cleanup problem (11 records when 1 expected)
- Failure A could also be DB-related: if a prior scenario's user records leaked, the login step might have found a different user or the session became invalid
- DB cleanup infrastructure:
  - `features/support/env.rb`: `DatabaseCleaner.strategy = :transaction` (default), `javascript_strategy = :truncation`
  - `Seeds.new.flushdb` runs once at env load (truncates all non-schema tables)
  - `Before do Kredis.redis.flushdb end` runs before each scenario
  - cucumber-rails handles `DatabaseCleaner.start`/`DatabaseCleaner.clean` via hooks in `cucumber-rails-4.0.0`

**Not yet fixed — needs investigation:**
- These are deeper infrastructure issues (DB cleanup between scenarios) rather than simple step definition fixes
- Possible fixes to explore:
  1. Ensure DatabaseCleaner.clean is called synchronously and completes before next scenario
  2. Use `:truncation` for ALL scenarios (slower but more reliable)
  3. Add explicit cleanup hooks for `@javascript` scenarios
  4. For the "Consulter" ambiguity: make the step click `first(:link_or_button, label)` instead of `find(:link_or_button, label)` as a defensive measure

### Task 8: Fix DatabaseCleaner cleanup between scenarios — SUCCESS
- Root cause: cucumber-rails only cleans in After hooks. If a `@javascript` scenario's
  truncation didn't fully complete (race condition with Puma server thread), leftover
  data leaks into the next scenario.
- Fix: Disabled `Cucumber::Rails::Database.autorun_database_cleaner` and replaced with
  our own hooks that add `DatabaseCleaner.clean` BEFORE `DatabaseCleaner.start` in the
  `Before` hook. This ensures any leaked data from the previous scenario is cleaned up.
- Strategy switching is now explicit: `Before('@javascript')` sets truncation,
  `Before('not @javascript')` sets transaction.
- Verified `DatabaseCleaner::ActiveRecord::Transaction#clean` safely no-ops when
  there's no open transaction (checks `open_transactions > 0`).
- Local test: 10 scenarios (mixed JS + non-JS) all pass.
- File modified: `features/support/env.rb`
- Rubocop: pass

### CI Run #4 (PR #1404, attempt 3 with Task 8 fix) — FAILED (2/501)
- `stats_page.feature:36` and `:42` — `undefined method 'cmd_tuples' for nil` in After hook
- Root cause: Our `DatabaseCleaner.clean` (truncation) in the After hook runs BEFORE
  Capybara's `reset_sessions!` (After hooks run in reverse definition order). Puma is
  still serving requests when we truncate, causing a PG adapter crash.
- The `habilitation_avec_des_cases_a_cocher_supplementaires.feature:42` flaky is GONE
  (Task 8 fix confirmed working).

### Task 9: Add Capybara.reset_sessions! before DatabaseCleaner.clean — SUCCESS
- Added `Capybara.reset_sessions!` before `DatabaseCleaner.clean` in the After hook
- This drains Puma of active requests before truncating tables
- Local test: 26 scenarios (all previously-failing features) pass
- File modified: `features/support/env.rb`
- Rubocop: pass

### Next steps:
- Push and monitor CI for flakiness reduction
