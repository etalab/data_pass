RSpec.describe Dashboard::BlankStateComponent, type: :component do
  let(:pictogram_path) { 'artwork/pictograms/document/document-add.svg' }
  let(:message) { 'Vous n\'avez pas encore de demandes en cours' }

  describe 'with default parameters' do
    let(:component) do
      render_inline(described_class.new(
        pictogram_path: pictogram_path,
        message: message
      ))
    end

    it 'renders the pictogram with default alt and class' do
      expect(component).to have_css('img[alt=""]')
      expect(component.css('img').first['src']).to include('document-add')
      expect(component).to have_css('img.fr-responsive-img.fr-artwork--large')
    end

    it 'renders the message' do
      expect(component).to have_text('Vous n\'avez pas encore de demandes en cours', normalize_ws: true)
    end

    it 'renders within the correct layout structure' do
      expect(component).to have_css('div.fr-py-12w')
      expect(component).to have_css('div.fr-grid-row.fr-grid-row--center')
      expect(component).to have_css('div.fr-col-12.fr-col-md-8.fr-col-lg-6.center')
    end

    it 'renders the message in a paragraph with correct styling' do
      expect(component).to have_css('p.fr-text--lg', text: 'Vous n\'avez pas encore de demandes en cours')
    end
  end

  describe 'with custom pictogram parameters' do
    let(:component) do
      render_inline(described_class.new(
        pictogram_path: pictogram_path,
        message: message,
        pictogram_alt: 'Illustration vide',
        pictogram_class: 'custom-class fr-responsive-img'
      ))
    end

    it 'renders the pictogram with custom alt text' do
      expect(component).to have_css('img[alt="Illustration vide"]')
    end

    it 'renders the pictogram with custom class' do
      expect(component).to have_css('img.custom-class.fr-responsive-img')
      expect(component).to have_no_css('img.fr-artwork--large')
    end
  end

  describe 'with action slot' do
    let(:component) do
      render_inline(described_class.new(
        pictogram_path: pictogram_path,
        message: message
      )) do |c|
        c.with_action do
          '<a href="https://example.com" class="fr-link">Action</a>'.html_safe
        end
      end
    end

    it 'renders the action content' do
      expect(component).to have_link('Action', href: 'https://example.com')
      expect(component).to have_css('a.fr-link')
    end
  end

  describe 'without action slot' do
    let(:component) do
      render_inline(described_class.new(
        pictogram_path: pictogram_path,
        message: message
      ))
    end

    it 'does not render action content' do
      expect(component).to have_no_link
    end
  end

  describe 'with button action' do
    let(:component) do
      render_inline(described_class.new(
        pictogram_path: 'artwork/pictograms/digital/information.svg',
        message: 'Aucun résultat trouvé'
      )) do |c|
        c.with_action do
          '<a href="/reset" class="fr-btn fr-btn--secondary">Réinitialiser</a>'.html_safe
        end
      end
    end

    it 'renders the button action' do
      expect(component).to have_link('Réinitialiser', href: '/reset')
      expect(component).to have_css('a.fr-btn.fr-btn--secondary')
    end
  end
end
