require 'rails_helper'

RSpec.describe Molecules::Instruction::UserRights::ReadonlyRightsListComponent, type: :component do
  def render_component(rights)
    render_inline(described_class.new(rights:))
  end

  it 'does not render when there is no readonly right' do
    render_component([])

    expect(page).to have_no_css('#readonly-rights')
  end

  it 'renders an info alert with the admin wording for an admin right' do
    render_component([{ scope: nil, role_type: 'admin' }])

    expect(page).to have_css('.fr-alert--info')
    expect(page).to have_text('Contactez un tech de l’équipe pour modifier un droit admin.')
  end

  it 'renders the alert title as an h4 (nested under the h3 readonly section)' do
    render_component([{ scope: nil, role_type: 'admin' }])

    expect(page).to have_css('h4.fr-alert__title')
  end

  context 'with a role type that has no specific wording' do
    before { render_component([{ scope: 'dinum:api_entreprise', role_type: 'some_role' }]) }

    it 'renders an info alert with the default wording' do
      expect(page).to have_css('.fr-alert--info')
      expect(page).to have_text('Ce droit n’est pas modifiable depuis cette interface.')
    end

    it 'lists the concerned scopes' do
      expect(page).to have_text(Instruction::Scope.new('dinum:api_entreprise').label)
    end
  end

  it 'groups several readonly rights of the same role into a single alert' do
    render_component(
      [
        { scope: 'dinum:api_entreprise', role_type: 'some_role' },
        { scope: 'dinum:api_particulier', role_type: 'some_role' }
      ]
    )

    expect(page).to have_css('.fr-alert--info', count: 1)
  end
end
