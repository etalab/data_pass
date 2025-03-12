RSpec.describe ExternalLinkComponent, type: :component do
  describe '#call' do
    let(:path) { 'https://example.com' }
    let(:text) { 'Visiter le site' }

    context 'when path is present' do
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
        expect(component).to have_css("a.fr-link[target='_blank'][rel='noopener']")
      end

      it 'renders link with the translation of the provided i18n key' do
        component = I18n.with_locale(:fr) do
          render_inline(described_class.new(
            i18n_key: 'dashboard.lien',
            path: path
          ))
        end

        expect(component).to have_link('Visiter le site', href: 'https://example.com')
      end

      it 'applies custom options while preserving default values' do
        component = render_inline(described_class.new(
          text: text,
          path: path,
          class: 'my-other-class'
        ))

        puts component.css('a').to_html

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
    end

    context 'when path is missing or nil' do
      it 'does not render link when path is missing' do
        component = render_inline(described_class.new(text: 'Texte'))
        expect(component.css('a')).to be_empty
      end

      it 'does not render link when path is empty' do
        component = render_inline(described_class.new(text: 'Texte', path: ''))
        expect(component.css('a')).to be_empty
      end
    end

    context 'when there is text priority' do
      it 'renders direct text rather than the i18n key if both are provided' do
        component = render_inline(described_class.new(
          text: text,
          i18n_key: 'key.that.should.not.be.present',
          path: path
        ))

        expect(component).to have_link('Visiter le site')
      end

      it 'renders an empty link if neither text of i18n key are provided' do
        component = render_inline(described_class.new(path: path))

        expect(component).to have_link(href: 'https://example.com')
        expect(component.text).to be_blank
      end
    end
  end
end
