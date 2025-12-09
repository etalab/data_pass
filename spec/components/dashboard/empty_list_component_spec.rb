RSpec.describe Dashboard::EmptyListComponent, type: :component do
  describe 'rendering for demandes tab' do
    it 'displays the pictogram' do
      component = render_inline(described_class.new(tab_type: 'demandes'))

      expect(component).to have_css('img[alt=""]')
      expect(component.css('img').first['src']).to include('document-add')
    end

    it 'displays the correct message' do
      component = render_inline(described_class.new(tab_type: 'demandes'))

      expect(component).to have_text('Vous n’avez pas encore de demandes en cours', normalize_ws: true)
    end

    it 'displays the CTA link with correct attributes' do
      component = render_inline(described_class.new(tab_type: 'demandes'))

      expect(component).to have_link('Demander un accès à des données', href: 'https://www.data.gouv.fr/fr/dataservices')
      expect(component).to have_css("a[target='_blank'][rel='noopener noreferrer']")
    end

    it 'has DSFR link styling with action-high-blue-france color' do
      component = render_inline(described_class.new(tab_type: 'demandes'))

      expect(component).to have_css('a.fr-link.fr-link--action-high-blue-france')
      expect(component).to have_no_css('a.fr-btn')
    end
  end

  describe 'rendering for habilitations tab' do
    it 'displays the correct message for habilitations' do
      component = render_inline(described_class.new(tab_type: 'habilitations'))

      expect(component).to have_text("Vous n’avez pas encore d’habilitations")
    end
  end
end
