RSpec.describe 'Dirigeant verification' do
  let(:user) { create(:user) }
  let(:dirigeant_payload) do
    OmniAuth::AuthHash.new(
      provider: :proconnect_dirigeant,
      uid: user.external_id,
      info: { email: user.email },
      extra: {
        acr: OmniAuth::Strategies::ProconnectDirigeant::DIRIGEANT_ACR_VALUE,
        raw_info: { sub: user.external_id, siret: user.current_organization.siret }
      }
    )
  end

  let(:organization_link) { user.organizations_users.find_by(organization: user.current_organization) }

  before { OmniAuth.config.mock_auth[:proconnect_dirigeant] = dirigeant_payload }

  after { OmniAuth.config.mock_auth[:proconnect_dirigeant] = nil }

  context 'when signed in' do
    before { sign_in(user) }

    it 'keeps the session when ProConnect calls back' do
      signed_in_session = session[:user_id].as_json.except('expires_at')
      session_id = session.id.to_s

      get '/auth/proconnect_dirigeant/callback'

      expect(response).to redirect_to(dirigeant_verification_path)
      expect(session[:user_id].as_json.except('expires_at')).to eq(signed_in_session)
      expect(session.id.to_s).to eq(session_id)
    end

    it 'shows the result without touching the user nor the organization' do
      expect {
        get '/auth/proconnect_dirigeant/callback'
        follow_redirect!
      }.not_to(change { [user.reload.updated_at, user.current_organization.reload.updated_at] })

      expect(response.body).to include('ProConnect certifie que vous êtes dirigeant de cette entreprise.')
    end

    it 'dates the certification on the link between the user and the current organization' do
      freeze_time do
        get '/auth/proconnect_dirigeant/callback'

        expect(organization_link.reload.dirigeant_verified_at).to eq(Time.zone.now)
      end
    end

    it 'revokes a previous certification when ProConnect does not certify' do
      get '/auth/proconnect_dirigeant/callback'
      dirigeant_payload.extra.acr = 'eidas1-mfa'
      get '/auth/proconnect_dirigeant/callback'

      expect(organization_link.reload.dirigeant_verified_at).to be_nil
    end

    it 'keeps a previous certification when the ProConnect account is not the signed-in one' do
      get '/auth/proconnect_dirigeant/callback'
      dirigeant_payload.uid = 'autre-sub'

      expect { get '/auth/proconnect_dirigeant/callback' }.not_to(change { organization_link.reload.dirigeant_verified_at })
    end

    it 'sends the user back to the page given as return_to' do
      post '/auth/proconnect_dirigeant', params: { return_to: '/demandes/registre/nouveau' }
      follow_redirect!

      expect(response).to redirect_to('/demandes/registre/nouveau')
    end

    it 'ignores a return_to pointing to another host' do
      post '/auth/proconnect_dirigeant', params: { return_to: '//evil.example/demandes' }
      follow_redirect!

      expect(response).to redirect_to(dirigeant_verification_path)
    end

    it 'keeps a local return_to in the verification form' do
      get dirigeant_verification_path, params: { return_to: '/demandes/registre/nouveau' }

      expect(response.body).to include('name="return_to" id="return_to" value="/demandes/registre/nouveau"')
    end

    it 'drops a return_to pointing to another host from the verification form' do
      get dirigeant_verification_path, params: { return_to: '//evil.example/demandes' }

      expect(response.body).not_to include('name="return_to"')
    end

    context 'when the user has no current organization' do
      before { user.organizations_users.update_all(current: false) }

      it 'offers the certification' do
        get dirigeant_verification_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('id="verify_dirigeant"')
      end

      it 'fails the certification for lack of SIREN' do
        get '/auth/proconnect_dirigeant/callback'

        expect(flash[:dirigeant_verification]).to eq('status' => 'failure', 'reason' => 'organization_without_siren')
      end
    end

    context 'when the organization belongs to the public sector' do
      let(:user) do
        create(:user, skip_organization_creation: true).tap do |public_agent|
          public_agent.add_to_organization(create(:organization, siret: '21920023500014'), current: true, verified: true)
        end
      end

      it 'explains the refusal without offering the certification' do
        get dirigeant_verification_path

        expect(response.body).to include('Votre organisation relève du secteur public')
        expect(response.body).not_to include('id="verify_dirigeant"')
      end

      it 'links back to a local return_to' do
        get dirigeant_verification_path, params: { return_to: '/demandes/registre/nouveau' }

        expect(response.body).to include('id="back_to_return_to" href="/demandes/registre/nouveau"')
      end

      it 'does not link back to a return_to pointing to another host' do
        get dirigeant_verification_path, params: { return_to: '//evil.example/demandes' }

        expect(response.body).not_to include('back_to_return_to')
      end

      it 'does not link back without return_to' do
        get dirigeant_verification_path

        expect(response.body).not_to include('back_to_return_to')
      end

      it 'keeps the return_to when refusing the certification on callback' do
        post '/auth/proconnect_dirigeant', params: { return_to: '/demandes/registre/nouveau' }
        follow_redirect!

        expect(response).to redirect_to(dirigeant_verification_path(return_to: '/demandes/registre/nouveau'))
      end

      it 'refuses the certification on callback' do
        get '/auth/proconnect_dirigeant/callback'

        expect(response).to redirect_to(dirigeant_verification_path)
        expect(flash[:dirigeant_verification]).to eq('status' => 'failure', 'reason' => 'organization_is_public_service')
      end
    end

    context 'when the feature is disabled' do
      before do
        allow(FeatureFlag).to receive(:enabled?).and_call_original
        allow(FeatureFlag).to receive(:enabled?).with(:proconnect_dirigeant).and_return(false)
      end

      it 'is not found' do
        get dirigeant_verification_path

        expect(response).to have_http_status(:not_found)
      end

      it 'does not verify anything on callback' do
        get '/auth/proconnect_dirigeant/callback'

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  context 'when not signed in' do
    it 'does not verify anything on callback' do
      get '/auth/proconnect_dirigeant/callback'

      expect(response).not_to redirect_to(dirigeant_verification_path)
      expect(flash[:dirigeant_verification]).to be_nil
    end
  end
end
