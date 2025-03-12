RSpec.describe HistoricalAuthorizationRequestEventComponent, type: :component do
  subject { described_class.new(authorization_request_event: authorization_request_event) }

  let(:authorization_request_event) { create(:authorization_request_event, :request_changes) }

  before do
    render_inline(subject)
  end

  describe '#message_content' do
    let(:expected_text) { "<strong>Dupont Jean</strong> a demandé des modifications sur la demande :\n <blockquote>\n  <p>Veuillez inclure une preuve de compétence en calligraphie, conformément à la nouvelle directive interne visant à améliorer la qualité visuelle des documents manuscrits officiels</p>\n</blockquote>" }

    it 'calls I18n translation key with the correct variables' do
      expect(subject.message_content.strip).to eq(expected_text)
    end

    it 'returns an HTML-safe string' do
      expect(subject.message_content).to be_html_safe
    end
  end

  describe 'render' do
    let(:expected_text) { "Dupont Jean a demandé des modifications sur la demande :\n\n\n Veuillez inclure une preuve de compétence en calligraphie, conformément à la nouvelle directive interne visant à améliorer la qualité visuelle des documents manuscrits officiels\n\n" }

    it 'renders component' do
      page = render_inline(subject)

      expect(page).to have_text('Dupont Jean a demandé des modifications sur la demande :')
      expect(page).to have_text('Veuillez inclure une preuve de compétence en calligraphie, conformément à la nouvelle directive interne visant à améliorer la qualité visuelle des documents manuscrits officiels')
    end
  end

  describe '#message_expandable?' do
    context 'when message_details_text is present' do
      it 'returns true' do
        expect(subject.message_expandable?).to be(true)
      end
    end

    context 'when message_details_text is nil' do
      let(:authorization_request_event) { create(:authorization_request_event, :approve) }

      it 'returns false' do
        render_inline(subject)

        expect(subject.message_expandable?).to be(false)
      end
    end
  end

  describe '#transfer_text' do
    let(:to_user) { create(:user, given_name: 'Edmond', family_name: 'Richard', email: 'edmondrichart@example.com') }
    let(:organization) { create(:organization, siret: '13002526500013') }

    context 'when an authorization_request has been transfer to an user' do
      let(:authorization_request_event) { create(:authorization_request_event, :transfer) }

      it 'returns the transfer text with the full name and email of the user' do
        authorization_request_event.entity.to = to_user

        expect(subject.transfer_text).to eq('Richard Edmond (edmondrichart@example.com)')
      end
    end

    context 'when an authorization_request has been transfer to an organization' do
      let(:authorization_request_event) { create(:authorization_request_event, :transfer) }

      it 'returns the transfer text with the raison sociale and SIRET from organization' do
        authorization_request_event.entity.from_type = organization
        authorization_request_event.entity.to = organization

        expect(subject.transfer_text).to eq("l'organisation DIRECTION INTERMINISTERIELLE DU NUMERIQUE (numéro SIRET : 13002526500013)")
      end
    end

    context 'when event name is submit' do
      let(:authorization_request_event) { create(:authorization_request_event, :submit) }

      it 'returns nil' do
        expect(subject.transfer_text).to be_nil
      end
    end
  end
end
