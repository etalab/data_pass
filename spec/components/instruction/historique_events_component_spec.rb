RSpec.describe Instruction::HistoricalEventsComponent, type: :component do
  subject { described_class.new(authorization_request_event: decorated_authorization_request_event) }

  let(:authorization_request_event) { create(:authorization_request_event, :request_changes) }
  let(:decorated_authorization_request_event) { AuthorizationRequestEventDecorator.new(authorization_request_event) }

  describe '#message_content' do
    let(:expected_text) { "<strong>Dupont Jean</strong> a demandé des modifications sur la demande:\n\n<blockquote>\n  <p>Veuillez inclure une preuve de compétence en calligraphie, conformément à la nouvelle directive interne visant à améliorer la qualité visuelle des documents manuscrits officiels</p>\n</blockquote>\n" }

    it 'calls I18n translation key with the correct variables' do
      expect(subject.message_content).to eq(expected_text)
    end

    it 'returns an HTML-safe string' do
      expect(subject.message_content).to be_html_safe
    end
  end

  describe '#text_present?' do
    context 'when text is present' do
      it 'returns true' do
        expect(subject.text_present?).to be(true)
      end
    end

    context 'when text is not present' do
      let(:authorization_request_event) { create(:authorization_request_event, :approve) }

      it 'returns false' do
        expect(subject.text_present?).to be(false)
      end
    end
  end
end
