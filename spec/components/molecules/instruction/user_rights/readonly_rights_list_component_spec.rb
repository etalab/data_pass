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

  it 'renders an info alert with the developer wording and lists the concerned scopes' do
    render_component([{ scope: 'dinum:api_entreprise', role_type: 'developer' }])

    expect(page).to have_css('.fr-alert--info')
    expect(page).to have_text('Contactez l’équipe DataPass pour modifier le droit développeur.')
    expect(page).to have_text(Instruction::Scope.new('dinum:api_entreprise').label)
  end

  it 'groups several readonly rights of the same role into a single alert' do
    render_component(
      [
        { scope: 'dinum:api_entreprise', role_type: 'developer' },
        { scope: 'dinum:api_particulier', role_type: 'developer' }
      ]
    )

    expect(page).to have_css('.fr-alert--info', count: 1)
  end
end
