RSpec.describe MarkdownRenderer do
  subject(:renderer) { described_class.new(content) }

  describe '#to_html' do
    subject(:html) { renderer.to_html }

    context 'with headings' do
      let(:content) { '# Titre principal' }

      it { is_expected.to include('<h1') }
      it { is_expected.to include('Titre principal') }
    end

    context 'with fenced code blocks' do
      let(:content) { "```json\n{\"key\": \"value\"}\n```" }

      it { is_expected.to include('<code') }
      it { is_expected.to include('{&quot;key&quot;: &quot;value&quot;}') }
    end

    context 'with tables' do
      let(:content) { "| Col1 | Col2 |\n|------|------|\n| A | B |" }

      it { is_expected.to include('<table>') }
      it { is_expected.to include('<td>A</td>') }
    end

    context 'with autolinks' do
      let(:content) { 'https://example.com' }

      it { is_expected.to include('<a href="https://example.com"') }
    end
  end
end
