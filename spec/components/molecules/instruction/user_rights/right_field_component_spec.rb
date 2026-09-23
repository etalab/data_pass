require 'rails_helper'

RSpec.describe Molecules::Instruction::UserRights::RightFieldComponent, type: :component do
  let(:api_entreprise) { AuthorizationDefinition.find('api_entreprise') }
  let(:manager) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }

  def render_component(index:, scope: '', role_type: '', actor: manager, editable: true)
    render_inline(
      described_class.new(
        index:,
        scope:,
        role_type:,
        permissions: Rights::ManagerAuthority.new(actor),
        editable:
      )
    )
  end

  context 'when the right lies outside the actor perimeter' do
    before { render_component(index: 'out-0', scope: 'dgfip:api_impot_particulier', role_type: 'reporter', editable: false) }

    it 'shows the right without letting it be changed' do
      expect(page).to have_css('select[disabled]', count: 2)
      expect(page).to have_text('Observateur')
    end

    it 'offers no way to remove it' do
      expect(page).to have_no_button
    end

    it 'says why it cannot be changed, for screen readers' do
      hint = page.find('p.fr-sr-only', text: 'pas modifiable')
      expect(page).to have_css("select[aria-describedby='#{hint[:id]}']", count: 2)
    end
  end

  it 'renders labelled selects for scope and role and a remove button' do
    render_component(index: 0)

    expect(page).to have_css('label[for="instruction_user_right_form_rights_0_scope"]', text: I18n.t('instruction.user_rights.new.scope_label'))
    expect(page).to have_select('instruction_user_right_form[rights][][scope]')
    expect(page).to have_css('label[for="instruction_user_right_form_rights_0_role_type"]', text: I18n.t('instruction.user_rights.new.role_label'))
    expect(page).to have_select('instruction_user_right_form[rights][][role_type]')
    expect(page).to have_css('button[data-action*="nested-form#remove"]')
  end

  it 'groups scope options by provider' do
    render_component(index: 0)

    expect(page).to have_css('optgroup[label="DINUM"]')
    expect(page).to have_select(
      'instruction_user_right_form[rights][][scope]',
      with_options: [api_entreprise.name]
    )
  end

  it 'exposes the FD-wildcard option when the actor is an FD-manager' do
    fd_manager = create(:user, roles: ['dinum:*:manager'])

    render_component(index: 0, actor: fd_manager)

    expect(page).to have_select(
      'instruction_user_right_form[rights][][scope]',
      with_options: ['Tous les services DINUM', api_entreprise.name]
    )
  end

  it 'lists reporter, instructor, manager and developer as role options' do
    render_component(index: 0)

    expect(page).to have_select(
      'instruction_user_right_form[rights][][role_type]',
      with_options: %w[Observateur Instructeur Manager Développeur]
    )
  end

  it 'pre-selects the provided values' do
    render_component(index: 2, scope: "dinum:#{api_entreprise.id}", role_type: 'manager')

    expect(page).to have_select(
      'instruction_user_right_form[rights][][scope]',
      selected: api_entreprise.name
    )
    expect(page).to have_select(
      'instruction_user_right_form[rights][][role_type]',
      selected: 'Manager'
    )
  end

  it 'uses the provided index for the field IDs (a11y label coupling)' do
    render_component(index: 2)

    expect(page).to have_select(id: 'instruction_user_right_form_rights_2_scope')
    expect(page).to have_select(id: 'instruction_user_right_form_rights_2_role_type')
  end

  it 'accepts a string placeholder index for the nested-form template' do
    render_component(index: 'NEW')

    expect(page).to have_select(id: 'instruction_user_right_form_rights_NEW_scope')
  end
end
