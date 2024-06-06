RSpec.describe AuthorizationRequestTransfer do
  it 'has valid factories' do
    expect(build(:authorization_request_transfer)).to be_valid
  end

  describe 'from and to users validation' do
    subject { build(:authorization_request_transfer, from: from_user, to: to_user) }

    let(:from_user) { create(:user) }

    context 'when to_user is the same as from_user' do
      let(:to_user) { from_user }

      it { is_expected.not_to be_valid }
    end

    context 'when to_user is different from from_user' do
      context 'when to_user is not from the same organization as from_user' do
        let(:to_user) { create(:user) }

        it { is_expected.not_to be_valid }
      end

      context 'when to_user is from the same organization as from_user' do
        let(:to_user) { create(:user, current_organization: from_user.current_organization) }

        it { is_expected.to be_valid }
      end
    end
  end
end
