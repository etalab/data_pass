RSpec.describe AuthorizationRequestTabsBuilder do
  include Rails.application.routes.url_helpers

  subject(:tabs) { described_class.new(authorization_request, policy).build }

  let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }
  let(:policy) { instance_double(AuthorizationRequestPolicy, events?: true, messages?: true, authorizations?: true) }

  describe '#build' do
    it 'always includes authorization_request tab' do
      expect(tabs).to have_key(:authorization_request)
      expect(tabs[:authorization_request]).to eq(
        summary_authorization_request_form_path(form_uid: authorization_request.form_uid, id: authorization_request.id)
      )
    end

    it 'returns tabs in correct order' do
      create(:authorization, request: authorization_request)

      expect(tabs.keys).to eq(%i[authorization_request authorization_request_events messages authorizations])
    end

    context 'when france_connect request with linked authorizations' do
      let(:authorization_request) { create(:authorization_request, :france_connect, :validated) }

      before do
        linked_auth = create(:authorization)
        linked_auth.data['france_connect_authorization_id'] = authorization_request.latest_authorization.id
        linked_auth.save!
      end

      it 'includes france_connected_authorizations tab' do
        expect(tabs).to have_key(:france_connected_authorizations)
        expect(tabs[:france_connected_authorizations]).to eq(
          authorization_request_france_connected_authorizations_path(authorization_request)
        )
      end
    end

    context 'when france_connect request without linked authorizations' do
      let(:authorization_request) { create(:authorization_request, :france_connect, :validated) }

      it 'does not include france_connected_authorizations tab' do
        expect(tabs).not_to have_key(:france_connected_authorizations)
      end
    end

    context 'when not a france_connect request' do
      it 'does not include france_connected_authorizations tab' do
        expect(tabs).not_to have_key(:france_connected_authorizations)
      end
    end

    context 'when policy allows authorizations and authorizations exist' do
      let(:policy) { instance_double(AuthorizationRequestPolicy, events?: false, messages?: false, authorizations?: true) }

      before { create(:authorization, request: authorization_request) }

      it 'includes authorizations tab' do
        expect(tabs).to have_key(:authorizations)
        expect(tabs[:authorizations]).to eq(authorization_request_authorizations_path(authorization_request))
      end
    end

    context 'when policy allows authorizations but no authorizations exist' do
      let(:policy) { instance_double(AuthorizationRequestPolicy, events?: false, messages?: false, authorizations?: true) }

      it 'does not include authorizations tab' do
        expect(tabs).not_to have_key(:authorizations)
      end
    end

    context 'when policy allows events' do
      let(:policy) { instance_double(AuthorizationRequestPolicy, events?: true, messages?: false, authorizations?: false) }

      it 'includes authorization_request_events tab' do
        expect(tabs).to have_key(:authorization_request_events)
        expect(tabs[:authorization_request_events]).to eq(authorization_request_events_path(authorization_request))
      end
    end

    context 'when policy allows messages' do
      let(:policy) { instance_double(AuthorizationRequestPolicy, events?: false, messages?: true, authorizations?: false) }

      it 'includes messages tab' do
        expect(tabs).to have_key(:messages)
        expect(tabs[:messages]).to eq(authorization_request_messages_path(authorization_request))
      end
    end

    context 'when policy denies authorizations' do
      let(:policy) { instance_double(AuthorizationRequestPolicy, events?: false, messages?: false, authorizations?: false) }

      before { create(:authorization, request: authorization_request) }

      it 'does not include authorizations tab' do
        expect(tabs).not_to have_key(:authorizations)
      end
    end

    context 'when policy denies events' do
      let(:policy) { instance_double(AuthorizationRequestPolicy, events?: false, messages?: false, authorizations?: false) }

      it 'does not include authorization_request_events tab' do
        expect(tabs).not_to have_key(:authorization_request_events)
      end
    end

    context 'when policy denies messages' do
      let(:policy) { instance_double(AuthorizationRequestPolicy, events?: false, messages?: false, authorizations?: false) }

      it 'does not include messages tab' do
        expect(tabs).not_to have_key(:messages)
      end
    end
  end
end
