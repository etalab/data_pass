RSpec.describe LinkComponent, type: :component do
  describe '#call' do
    let(:path) { 'https://example.com' }
    let(:text) { 'Visiter le site' }

    before do
      fr = {
        dashboard: {
          lien: 'Visiter le site'
        }
      }

      I18n.backend.store_translations(:fr, fr)
    end

    it 'renders link with text' do
      component = render_inline(described_class.new(
        text: text,
        path: path
      ))

      expect(component).to have_link('Visiter le site', href: 'https://example.com')
      expect(component).to have_css("a.fr-link[rel='noopener']")
      expect(component).not_to have_css("a[target='_blank']")
    end

    it 'applies custom options while preserving default values' do
      component = render_inline(described_class.new(
        text: text,
        path: path,
        class: 'my-other-class',
        target: '_blank'

      ))

      expect(component).to have_css('a.fr-link.my-other-class')
      expect(component).to have_css("a[target='_blank'][rel='noopener']")
    end

    it 'replaces default options with those provided' do
      component = render_inline(described_class.new(
        text: 'Autre target',
        path: path,
        target: '_self'
      ))

      expect(component).to have_css("a[target='_self']")
    end

    it 'accepts translated text as input' do
      translated_text = I18n.t('dashboard.lien')
      component = render_inline(described_class.new(
        text: translated_text,
        path: path
      ))

      expect(component).to have_link('Visiter le site', href: 'https://example.com')
    end
  end
end
