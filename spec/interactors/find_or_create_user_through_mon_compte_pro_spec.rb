RSpec.describe FindOrCreateUserThroughMonComptePro do
  describe '#call' do
    subject(:find_or_create_user) { described_class.call(mon_compte_pro_omniauth_payload:, user_attributes: { current_organization: create(:organization) }) }

    let(:payload_overrides) { {} }
    let(:removed_payload_keys) { [] }
    let(:mon_compte_pro_omniauth_payload) do
      build(
        :mon_compte_pro_omniauth_payload,
        info: build(:mon_compte_pro_payload, **payload_overrides)
      ).tap { |payload| payload['info'].except!(*removed_payload_keys) }
    end

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
        expect(user.phone_number).to eq(mon_compte_pro_omniauth_payload['info']['phone_number'])
        expect(user.phone_number_verified).to eq(mon_compte_pro_omniauth_payload['info']['phone_number_verified'])
      end

      it 'returns the user' do
        expect(find_or_create_user.user).to be_a(User)
      end
    end

    context 'when user already exists' do
      let!(:user) do
        create(
          :user,
          email: mon_compte_pro_omniauth_payload['info']['email'],
          external_id: mon_compte_pro_omniauth_payload['uid'],
          family_name: 'Martin',
          given_name: 'Camille',
          phone_number: '0102030405',
          phone_number_verified: true,
          job_title: 'Adjoint au maire'
        )
      end

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
        expect(user.phone_number).to eq(mon_compte_pro_omniauth_payload['info']['phone_number'])
        expect(user.phone_number_verified).to eq(mon_compte_pro_omniauth_payload['info']['phone_number_verified'])
      end

      it 'synchronizes phone_number_verified even when false' do
        expect { find_or_create_user }.to change { user.reload.phone_number_verified }.from(true).to(false)
      end

      it_behaves_like 'an identity attribute synchronized only when filled', 'family_name', 'family_name', 'Durand'
      it_behaves_like 'an identity attribute synchronized only when filled', 'given_name', 'given_name', 'Dominique'
      it_behaves_like 'an identity attribute synchronized only when filled', 'phone_number', 'phone_number', '0611223344'
      it_behaves_like 'an identity attribute synchronized only when filled', 'job_title', 'job', 'Secrétaire de mairie'
    end
  end
end
