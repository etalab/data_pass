RSpec.describe AuthorizationTabsBuilder do
  include Rails.application.routes.url_helpers

  subject(:tabs) { described_class.new(authorization, policy).build }

  let(:authorization) { create(:authorization) }
  let(:policy) { instance_double(AuthorizationPolicy, events?: true, messages?: true, authorizations?: true) }

  describe '#build' do
    it 'always includes authorization tab' do
      expect(tabs).to have_key(:authorization)
      expect(tabs[:authorization]).to eq(authorization_path(authorization))
    end

    it 'returns tabs in correct order' do
      expect(tabs.keys).to eq(%i[authorization authorization_request_events messages authorizations])
    end

    context 'when france_connect authorization with linked authorizations' do
      let(:authorization_request) { create(:authorization_request, :france_connect, :validated) }
      let(:authorization) { authorization_request.latest_authorization }

      before do
        linked_auth = create(:authorization)
        linked_auth.data['france_connect_authorization_id'] = authorization.id
        linked_auth.save!
      end

      it 'includes france_connected_authorizations tab' do
        expect(tabs).to have_key(:france_connected_authorizations)
        expect(tabs[:france_connected_authorizations]).to eq(
          authorization_france_connected_authorizations_path(authorization)
        )
      end
    end

    context 'when france_connect authorization without linked authorizations' do
      let(:authorization_request) { create(:authorization_request, :france_connect, :validated) }
      let(:authorization) { authorization_request.latest_authorization }

      it 'does not include france_connected_authorizations tab' do
        expect(tabs).not_to have_key(:france_connected_authorizations)
      end
    end

    context 'when not a france_connect authorization' do
      it 'does not include france_connected_authorizations tab' do
        expect(tabs).not_to have_key(:france_connected_authorizations)
      end
    end

    context 'when policy allows authorizations' do
      let(:policy) { instance_double(AuthorizationPolicy, events?: false, messages?: false, authorizations?: true) }

      it 'includes authorizations tab' do
        expect(tabs).to have_key(:authorizations)
        expect(tabs[:authorizations]).to eq(authorization_request_authorizations_path(authorization.request))
      end
    end

    context 'when policy allows events' do
      let(:policy) { instance_double(AuthorizationPolicy, events?: true, messages?: false, authorizations?: false) }

      it 'includes authorization_request_events tab' do
        expect(tabs).to have_key(:authorization_request_events)
        expect(tabs[:authorization_request_events]).to eq(authorization_events_path(authorization))
      end
    end

    context 'when policy allows messages' do
      let(:policy) { instance_double(AuthorizationPolicy, events?: false, messages?: true, authorizations?: false) }

      it 'includes messages tab' do
        expect(tabs).to have_key(:messages)
        expect(tabs[:messages]).to eq(authorization_messages_path(authorization))
      end
    end

    context 'when policy denies authorizations' do
      let(:policy) { instance_double(AuthorizationPolicy, events?: false, messages?: false, authorizations?: false) }

      it 'does not include authorizations tab' do
        expect(tabs).not_to have_key(:authorizations)
      end
    end

    context 'when policy denies events' do
      let(:policy) { instance_double(AuthorizationPolicy, events?: false, messages?: false, authorizations?: false) }

      it 'does not include authorization_request_events tab' do
        expect(tabs).not_to have_key(:authorization_request_events)
      end
    end

    context 'when policy denies messages' do
      let(:policy) { instance_double(AuthorizationPolicy, events?: false, messages?: false, authorizations?: false) }

      it 'does not include messages tab' do
        expect(tabs).not_to have_key(:messages)
      end
    end
  end
end
