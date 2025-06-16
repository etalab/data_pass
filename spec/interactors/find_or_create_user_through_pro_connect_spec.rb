RSpec.describe FindOrCreateUserThroughProConnect do
  describe '#call' do
    subject(:find_or_create_user) { described_class.call(pro_connect_omniauth_payload:) }

    let(:pro_connect_omniauth_payload) { build(:proconnect_omniauth_payload) }

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

        expect(user.email).to eq(pro_connect_omniauth_payload.dig('extra', 'raw_info', 'email'))

        expect(user.family_name).not_to be_nil
        expect(user.family_name).to eq(pro_connect_omniauth_payload.dig('extra', 'raw_info', 'usual_name'))

        expect(user.given_name).not_to be_nil
        expect(user.given_name).to eq(pro_connect_omniauth_payload.dig('extra', 'raw_info', 'given_name'))

        expect(user.phone_number).not_to be_nil
        expect(user.phone_number).to eq(pro_connect_omniauth_payload.dig('extra', 'raw_info', 'phone_number'))

        expect(user.external_id).not_to be_nil
        expect(user.external_id).to eq(pro_connect_omniauth_payload.dig('extra', 'raw_info', 'sub'))
      end
    end

    context 'when user already exists' do
      let!(:user) { create(:user, email: pro_connect_omniauth_payload.dig('info', 'email')) }

      it 'does not create a new user' do
        expect { find_or_create_user }.not_to change(User, :count)
      end

      it 'returns the user' do
        expect(find_or_create_user.user).to eq(user)
      end

      it 'updates attributes' do
        find_or_create_user

        user.reload
        expect(user.family_name).to eq(pro_connect_omniauth_payload.dig('info', 'last_name'))
        expect(user.given_name).to eq(pro_connect_omniauth_payload.dig('info', 'first_name'))
        expect(user.external_id).to eq(pro_connect_omniauth_payload.dig('extra', 'raw_info', 'sub'))
      end
    end
  end
end
