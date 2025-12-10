RSpec.describe Dashboard::TabBlankStateComponent, type: :component do
  describe 'with reason: :empty' do
    describe 'rendering for demandes tab' do
      let(:component) { render_inline(described_class.new(tab_type: 'demandes', reason: :empty)) }

      it 'displays the document-add pictogram' do
        expect(component).to have_css('img[alt=""]')
        expect(component.css('img').first['src']).to include('document-add')
      end

      it 'displays the correct message' do
        expect(component).to have_text('Vous n’avez pas encore de demandes en cours', normalize_ws: true)
      end

      it 'displays the CTA link with correct attributes' do
        expect(component).to have_link('Demander un accès à des données', href: 'https://www.data.gouv.fr/fr/dataservices')
        expect(component).to have_css("a[target='_blank'][rel='noopener noreferrer']")
      end

      it 'has DSFR link styling with action-high-blue-france color' do
        expect(component).to have_css('a.fr-link.fr-link--action-high-blue-france')
        expect(component).to have_no_css('a.fr-btn')
      end
    end

    describe 'rendering for habilitations tab' do
      let(:component) { render_inline(described_class.new(tab_type: 'habilitations', reason: :empty)) }

      it 'displays the correct message for habilitations' do
        expect(component).to have_text('Vous n’avez pas encore d’habilitations')
      end
    end
  end

  describe 'with reason: :no_results' do
    describe 'rendering for demandes tab' do
      let(:component) { render_inline(described_class.new(tab_type: 'demandes', reason: :no_results)) }

      it 'displays the information pictogram' do
        expect(component).to have_css('img[alt=""]')
        expect(component.css('img').first['src']).to include('information')
      end

      it 'displays the no results message for demandes' do
        expect(component).to have_text('Nous n’avons pas trouvé de demande avec les filtres que vous avez sélectionné', normalize_ws: true)
      end

      it 'displays a reset filters button' do
        expect(component).to have_link('Réinitialiser les filtres', href: '/tableau-de-bord/demandes')
        expect(component).to have_css('a.fr-btn.fr-btn--secondary')
      end
    end

    describe 'rendering for habilitations tab' do
      let(:component) { render_inline(described_class.new(tab_type: 'habilitations', reason: :no_results)) }

      it 'displays the no results message for habilitations' do
        expect(component).to have_text('Nous n’avons pas trouvé d’habilitation avec les filtres que vous avez sélectionné', normalize_ws: true)
      end
    end
  end

  describe 'validation' do
    it 'raises an error for invalid reason' do
      expect {
        described_class.new(tab_type: 'demandes', reason: :invalid)
      }.to raise_error(ArgumentError, /reason must be one of/)
    end
  end
end
