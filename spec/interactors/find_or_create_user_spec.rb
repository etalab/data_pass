RSpec.describe FindOrCreateUser do
  describe '#call' do
    subject(:find_or_create_user) { described_class.call(mon_compte_pro_omniauth_payload:, user_attributes: { current_organization: create(:organization) }) }

    let(:mon_compte_pro_omniauth_payload) { build(:mon_compte_pro_omniauth_payload) }

    it { is_expected.to be_a_success }

    context 'when the user does not exist' do
      it 'creates a new user' do
        expect { find_or_create_user }.to change(User, :count).by(1)
      end

      it 'assigns the user attributes' do
        find_or_create_user

        user = User.last

        expect(user.email).to eq(mon_compte_pro_omniauth_payload['info']['email'])
        expect(user.external_id).to eq(mon_compte_pro_omniauth_payload['uid'])
        expect(user.family_name).to eq(mon_compte_pro_omniauth_payload['info']['family_name'])
        expect(user.given_name).to eq(mon_compte_pro_omniauth_payload['info']['given_name'])
        expect(user.job_title).to eq(mon_compte_pro_omniauth_payload['info']['job'])
        expect(user.email_verified).to eq(mon_compte_pro_omniauth_payload['info']['email_verified'])
      end

      it 'returns the user' do
        expect(find_or_create_user.user).to be_a(User)
      end
    end

    context 'when user already exists' do
      let!(:user) { create(:user, job_title: 'Adjoint au maire', external_id: mon_compte_pro_omniauth_payload['uid'], email: mon_compte_pro_omniauth_payload['info']['email']) }

      it 'does not create a new user' do
        expect { find_or_create_user }.not_to change(User, :count)
      end

      it 'returns the user' do
        expect(find_or_create_user.user).to eq(user)
      end

      it 'updates attributes' do
        find_or_create_user

        user.reload

        expect(user.email).to eq(mon_compte_pro_omniauth_payload['info']['email'])
        expect(user.external_id).to eq(mon_compte_pro_omniauth_payload['uid'])
        expect(user.family_name).to eq(mon_compte_pro_omniauth_payload['info']['family_name'])
        expect(user.given_name).to eq(mon_compte_pro_omniauth_payload['info']['given_name'])
        expect(user.job_title).to eq(mon_compte_pro_omniauth_payload['info']['job'])
        expect(user.email_verified).to eq(mon_compte_pro_omniauth_payload['info']['email_verified'])
      end
    end
  end
end
