RSpec.describe User do
  it 'has valid factories' do
    expect(build(:user)).to be_valid
    expect(build(:user, :instructor)).to be_valid
  end

  describe '#instructor?' do
    subject { user.instructor?(authorization_request_type) }

    context 'when user is not an instructor' do
      let(:user) { build(:user) }

      context 'without authorization_request_type' do
        let(:authorization_request_type) { nil }

        it { is_expected.to be_falsey }
      end

      context 'with authorization_request_type' do
        let(:authorization_request_type) { 'api_entreprise' }

        it { is_expected.to be_falsey }
      end
    end

    context 'when user is an instructor' do
      let(:user) { build(:user, :instructor, authorization_request_types: %w[api_entreprise]) }

      context 'without authorization_request_type' do
        let(:authorization_request_type) { nil }

        it { is_expected.to be_truthy }
      end

      context 'with authorization_request_type' do
        context 'when authorization_request_type matches' do
          let(:authorization_request_type) { 'api_entreprise' }

          it { is_expected.to be_truthy }
        end

        context 'when authorization_request_type does not matche' do
          let(:authorization_request_type) { 'api_particulier' }

          it { is_expected.to be_falsey }
        end
      end
    end
  end

  describe '#authorization_roles_as' do
    subject { user.authorization_roles_as(kind) }

    let(:kind) { 'instructor' }

    context 'when user is not an instructor' do
      let(:user) { build(:user) }

      it { is_expected.to be_empty }
    end

    context 'when user is an instructor' do
      let(:user) { build(:user, :instructor, authorization_request_types:) }
      let(:authorization_request_types) { %w[api_entreprise api_particulier] }

      it { is_expected.to contain_exactly('api_entreprise', 'api_particulier') }
    end
  end
end
