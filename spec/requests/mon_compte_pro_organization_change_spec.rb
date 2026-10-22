RSpec.describe 'GET /auth/mon_compte_pro/callback' do
  subject(:organization_change) { get '/auth/mon_compte_pro/callback' }

  let(:user) { create(:user) }
  let(:other_organization_siret) { '13002526500013' }
  let(:mon_compte_pro_email) { user.email }

  before do
    allow(Sentry).to receive(:capture_message)

    OmniAuth.config.mock_auth[:mon_compte_pro] = OmniAuth::AuthHash.new(
      provider: :mon_compte_pro,
      uid: user.external_id,
      info: attributes_for(:mon_compte_pro_payload, email: mon_compte_pro_email, siret: other_organization_siret)
    )
  end

  after do
    OmniAuth.config.mock_auth[:mon_compte_pro] = nil
  end

  context 'when the user is signed in through ProConnect' do
    before { sign_in(user) }

    it 'changes the current organization through a verified link' do
      organization_change

      current_organization_link = user.reload.organizations_users.find_by(current: true)

      expect(current_organization_link.organization.siret).to eq(other_organization_siret)
      expect(current_organization_link).to be_verified
    end

    it 'keeps the ProConnect session' do
      organization_change

      expect(session[:user_id]).to include('value' => user.id, 'identity_federator' => 'proconnect')
    end

    context 'when the user has been banned since signing in' do
      before { user.update!(banned_at: Time.current, ban_reason: 'Usurpation') }

      it 'does not change the current organization' do
        expect { organization_change }.not_to change { user.reload.current_organization }
      end
    end

    context 'when MonComptePro returns another email' do
      let(:mon_compte_pro_email) { 'autre-agent@gouv.fr' }

      it 'does not change the current organization' do
        expect { organization_change }.not_to change { user.reload.current_organization }
      end

      it 'redirects to the home page' do
        organization_change

        expect(response).to redirect_to(root_path)
      end
    end
  end

  context 'when nobody is signed in' do
    it 'does not open a session' do
      organization_change

      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to be_nil
    end

    it 'reports the rejected organization change to Sentry' do
      organization_change

      expect(Sentry).to have_received(:capture_message).with(
        'MonComptePro organization change rejected: no matching ProConnect session',
        level: :warning,
        extra: { signed_in: false, identity_federator: nil }
      )
    end
  end
end
