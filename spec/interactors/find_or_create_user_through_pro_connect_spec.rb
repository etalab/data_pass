RSpec.describe FindOrCreateUserThroughProConnect do
  describe '#call' do
    subject(:find_or_create_user) { described_class.call(pro_connect_omniauth_payload:) }

    let(:payload_overrides) { {} }
    let(:removed_payload_keys) { [] }
    let(:pro_connect_omniauth_payload) do
      build(
        :proconnect_omniauth_payload,
        extra: { 'raw_info' => build(:proconnect_raw_info_payload, **payload_overrides) }
      ).tap { |payload| payload['extra']['raw_info'].except!(*removed_payload_keys) }
    end
    let(:raw_info) { pro_connect_omniauth_payload.dig('extra', 'raw_info') }

    it { is_expected.to be_a_success }

    context 'when the user does not exist' do
      it 'creates a new user' do
        expect { find_or_create_user }.to change(User, :count).by(1)
      end

      it 'returns the user' do
        expect(find_or_create_user.user).to be_a(User)
      end

      it 'assigns the user attributes' do
        user = find_or_create_user.user

        expect(user.email).to eq(raw_info['email'])

        expect(user.family_name).not_to be_nil
        expect(user.family_name).to eq(raw_info['usual_name'])

        expect(user.given_name).not_to be_nil
        expect(user.given_name).to eq(raw_info['given_name'])

        expect(user.phone_number).not_to be_nil
        expect(user.phone_number).to eq(raw_info['phone_number'])

        expect(user.external_id).not_to be_nil
        expect(user.external_id).to eq(raw_info['sub'])
      end

      context 'when the identity provider does not send the phone number' do
        let(:removed_payload_keys) { ['phone_number'] }

        it 'creates the user without phone number' do
          expect(find_or_create_user.user.phone_number).to be_nil
        end
      end
    end

    context 'when user already exists' do
      let!(:user) do
        create(
          :user,
          email: raw_info['email'],
          family_name: 'Martin',
          given_name: 'Camille',
          phone_number: '0102030405',
          job_title: 'Cheffe de projet'
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
        expect(user.family_name).to eq(raw_info['usual_name'])
        expect(user.given_name).to eq(raw_info['given_name'])
        expect(user.phone_number).to eq(raw_info['phone_number'])
        expect(user.external_id).to eq(raw_info['sub'])
      end

      it 'keeps the existing job title' do
        expect { find_or_create_user }.not_to change { user.reload.job_title }
      end

      it_behaves_like 'an identity attribute synchronized only when filled', 'phone_number', 'phone_number', '0611223344'
      it_behaves_like 'an identity attribute synchronized only when filled', 'given_name', 'given_name', 'Dominique'
      it_behaves_like 'an identity attribute synchronized only when filled', 'family_name', 'usual_name', 'Durand'
    end
  end
end
