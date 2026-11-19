require 'rails_helper'

RSpec.describe Molecules::PhoneMockupComponent, type: :component do
  subject(:rendered) { render_inline(component) }

  let(:component) do
    described_class.new(
      caption: { id: 'legende', text: 'Exemple fictif' },
      header: { avatar: 'E', title: 'Exemple Vélos', subtitle: 'souhaite accéder à vos données' },
      rows: [{ label: 'Pourquoi', value: 'Créer votre compte client' }],
      status: 'Organisation enregistrée',
      actions: %w[Refuser Partager]
    )
  end

  it 'hides the drawing and labels the figure with a screen reader caption' do
    expect(rendered).to have_css('figure[aria-labelledby="legende"] .lp-phone[aria-hidden="true"]')
    expect(rendered).to have_css('figcaption#legende.fr-sr-only', text: 'Exemple fictif')
  end

  it 'renders rows, status and actions' do
    expect(rendered).to have_css('.lp-phone__row', text: 'PourquoiCréer votre compte client')
    expect(rendered).to have_css('.lp-phone__ok', text: 'Organisation enregistrée')
    expect(rendered).to have_css('.lp-phone__btns span', count: 2)
  end

  context 'without status nor actions' do
    let(:component) do
      described_class.new(caption: { id: 'legende', text: 'Exemple' }, header: { avatar: 'A', title: 'Titre', subtitle: 'Sous-titre' }, rows: [])
    end

    it 'renders neither' do
      expect(rendered).to have_no_css('.lp-phone__ok')
      expect(rendered).to have_no_css('.lp-phone__btns')
    end
  end
end
