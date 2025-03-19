RSpec.describe HistoricalAuthorizationRequestEventComponent, type: :component do
  subject { described_class.new(authorization_request_event: authorization_request_event) }

  describe '#message_content' do
    let(:authorization_request_event) { create(:authorization_request_event, :request_changes) }

    let(:message_summary_text) { '<strong>Dupont Jean</strong> a demandé des modifications sur la demande :' }
    let(:message_details_text) { 'Un message personnalisé de modification' }

    it 'includes the expected message summary and message details text' do
      authorization_request_event.entity.reason = message_details_text
      render_inline(subject)

      expect(subject.message_content).to include(message_summary_text)
      expect(subject.message_content).to include(message_details_text)
    end

    it 'returns an HTML-safe string' do
      render_inline(subject)

      expect(subject.message_content).to be_html_safe
    end
  end

  describe 'render' do
    context 'when event_name is submit' do
      let(:authorization_request_event) { create(:authorization_request_event, :create) }

      let(:expected_submit_text) { 'Dupont Jean a crée la demande.' }

      it 'renders component with message_summary only' do
        page = render_inline(subject)

        expect(page).to have_text(expected_submit_text)
      end
    end

    context 'when event_name is revoke' do
      let(:authorization_request_event) { create(:authorization_request_event, :revoke) }
      let(:message_summary_text) { 'Dupont Jean a révoqué la demande :' }
      let(:revoked_reason) { 'Une nouvelle habilitation a été ouverte et remplace celle ci' }

      it 'renders component with message_content' do
        authorization_request_event.entity.reason = revoked_reason
        page = render_inline(subject)

        expect(page).to have_text(message_summary_text)
        expect(page).to have_text(revoked_reason)
      end
    end
  end

  describe '#message_expandable?' do
    context 'when message_details_text is present' do
      let(:authorization_request_event) { create(:authorization_request_event, :refuse) }

      it 'returns true' do
        render_inline(subject)
        expect(rendered_content).to have_css('button[data-action="click->show-and-hide#trigger"]')
      end
    end

    context 'when message_details_text is not present' do
      let(:authorization_request_event) { create(:authorization_request_event, :approve) }

      it 'returns false' do
        render_inline(subject)
        expect(rendered_content).to have_no_css('button[data-action="click->show-and-hide#trigger"]')
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
        render_inline(subject)

        expect(subject.transfer_text).to eq('Richard Edmond (edmondrichart@example.com)')
      end
    end

    context 'when an authorization_request has been transfer to an organization' do
      let(:authorization_request_event) { create(:authorization_request_event, :transfer) }

      it 'returns the transfer text with the raison sociale and SIRET from organization' do
        authorization_request_event.entity.from_type = organization
        authorization_request_event.entity.to = organization

        render_inline(subject)

        expect(subject.transfer_text).to eq("l'organisation DIRECTION INTERMINISTERIELLE DU NUMERIQUE (numéro SIRET : 13002526500013)")
      end
    end

    context 'when event name is submit' do
      let(:authorization_request_event) { create(:authorization_request_event, :submit) }

      it 'returns nil' do
        render_inline(subject)

        expect(subject.transfer_text).to be_nil
      end
    end
  end
end
