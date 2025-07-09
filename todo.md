# Instruction Dashboard Authorization Search - Test Coverage TODO

## Current Status
- ✅ Authorization Requests tab ("demandes") has comprehensive test coverage in `spec/features/instruction/search_demandes_spec.rb`
- ✅ **Authorization tab ("habilitations") now has comprehensive test coverage in `spec/features/instruction/search_habilitations_spec.rb`**
- ❌ Turbo frame integration not fully tested
- ❌ Auto-submit form behavior not tested
- ❌ Tab switching functionality not tested

## Missing Test Coverage

### 1. Authorization Search RSpec Tests
- [x] ✅ **COMPLETED**: Create comprehensive authorization search tests following the same pattern as authorization requests
- [x] ✅ **COMPLETED**: Test authorization-specific search functionality:
  - [x] ✅ Text search with state and authorization request class filters
  - [x] ✅ Organization SIRET and name searches for authorizations
  - [x] ✅ Applicant email and family name searches for authorizations
  - [x] ✅ ID-based searches with proper authorization checks
  - [x] ✅ Authorization state filtering (using Authorization.state_machine.states)
  - [x] ✅ Authorization request class filtering (conditional on user roles)
  - [x] ✅ Sorting functionality (id, state, created_at)
  - [x] ✅ Pagination testing
  - [x] ✅ Results count display

**📁 Created: `spec/features/instruction/search_habilitations_spec.rb`**
**🎯 All 10 tests pass with 0 failures**

### 2. Turbo Frame Integration Tests
- [ ] Test frame-based navigation between tabs ('demandes' ↔ 'habilitations')
- [ ] Test `turbo_frame: 'tabs'` behavior in search forms
- [ ] Test `authorizations_table` frame updates
- [ ] Test auto-submit form behavior with debouncing (300ms interval)
- [ ] Test `auto-submit-form` Stimulus controller integration

### 3. Controller Logic Coverage
- [ ] Test `Instruction::DashboardController` authorization logic paths
- [ ] Test `params[:id] == 'habilitations'` vs `params[:id] == 'demandes'` branching
- [ ] Test search params persistence via cookies
- [ ] Test ID-based redirect functionality for authorizations
- [ ] Test authorization policy checks in search

### 4. Authorization-Specific Features
- [ ] Test conditional authorization request class filter (only shown when user has multiple roles)
- [ ] Test authorization state machine states filtering
- [ ] Test authorization definition name display
- [ ] Test authorization badges (status and stage)
- [ ] Test clickable rows with authorization paths

### 5. Cucumber Features (Optional)
- [ ] End-to-end authorization search workflows
- [ ] User journey testing for instructor workflows
- [ ] Cross-browser compatibility testing

## Implementation Order (TDD Approach)

1. ✅ **COMPLETED**: Basic authorization search functionality - Following existing patterns
2. ✅ **COMPLETED**: Authorization-specific search tests - All search scenarios covered
3. **NEXT**: Add Turbo frame integration tests - Focus on frame updates
4. **FUTURE**: Add controller logic tests - If needed for complex authorization logic
5. **FUTURE**: Refactor - Clean up any duplication between authorization and authorization_request tests

## Technical Notes

- ✅ **COMPLETED**: Followed TDD Red → Green → Refactor cycle
- ✅ **COMPLETED**: Used same test patterns as existing authorization request tests
- ✅ **COMPLETED**: Ensured proper factory setup for authorization test data
- ✅ **COMPLETED**: Tested both happy path and edge cases
- ✅ **COMPLETED**: Maintained test isolation and proper cleanup
- ✅ **RESOLVED**: Fixed factory usage (`:submitted` vs `:validated` trait)
- ✅ **RESOLVED**: Added Bullet safelist for Authorization => :request association
