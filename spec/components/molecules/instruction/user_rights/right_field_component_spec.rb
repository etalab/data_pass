require 'rails_helper'

RSpec.describe Molecules::Instruction::UserRights::RightFieldComponent, type: :component do
  let(:api_entreprise) { AuthorizationDefinition.find('api_entreprise') }
  let(:manager) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }

  def render_component(index:, scope: '', role_type: '', actor: manager)
    render_inline(
      described_class.new(
        index:,
        scope:,
        role_type:,
        permissions: Instruction::ManagerScopeOptions.new(actor)
      )
    )
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

  it 'lists only reporter, instructor and manager as role options' do
    render_component(index: 0)

    expect(page).to have_select(
      'instruction_user_right_form[rights][][role_type]',
      with_options: %w[Reporter Instructeur Manager]
    )
    expect(page).to have_no_select(
      'instruction_user_right_form[rights][][role_type]',
      with_options: %w[Développeur]
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
