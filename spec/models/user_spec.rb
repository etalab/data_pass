RSpec.describe User do
  it 'has valid factories' do
    expect(build(:user)).to be_valid
    expect(build(:user, :instructor)).to be_valid
  end

  describe '.reporter_for' do
    subject { described_class.reporter_for(authorization_request_type) }

    let(:authorization_request_type) { 'api_entreprise' }

    let!(:valid_instructor) { create(:user, :instructor, authorization_request_types: %i[api_entreprise]) }
    let!(:valid_instructor_with_multiple_authorization_type) { create(:user, :instructor, authorization_request_types: %i[api_entreprise api_particulier]) }
    let!(:invalid_instructor) { create(:user, :instructor, authorization_request_types: %i[api_particulier]) }
    let!(:valid_reporter) { create(:user, :reporter, authorization_request_types: %i[api_entreprise]) }

    it { is_expected.to contain_exactly(valid_reporter, valid_instructor, valid_instructor_with_multiple_authorization_type) }
  end

  describe '#reporter?' do
    subject { user.reporter?(authorization_request_type) }

    context 'when user is not a reporter' do
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

    context 'when user is a reporter' do
      let(:user) { build(:user, :reporter, authorization_request_types: %w[api_entreprise]) }

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

  describe '#authorization_definition_roles_as' do
    subject { user.authorization_definition_roles_as(kind).map(&:id) }

    let(:kind) { 'instructor' }

    context 'when user is not an instructor' do
      let(:user) { build(:user) }

      it { is_expected.to be_empty }
    end

    context 'when user is an instructor' do
      let(:user) { build(:user, :instructor, authorization_request_types:) }
      let(:authorization_request_types) { %w[api_entreprise api_particulier] }

      let(:api_entreprise_definition) { AuthorizationDefinition.find('api_entreprise') }
      let(:api_particulier_definition) { AuthorizationDefinition.find('api_particulier') }

      it { is_expected.to contain_exactly('api_entreprise', 'api_particulier') }
    end
  end

  describe '#settings on instruction_submit_notifications' do
    subject { user.instruction_submit_notifications_for_api_entreprise }

    let(:user) { create(:user) }

    it { is_expected.to be_truthy }

    context 'when it sets to false' do
      let(:user) { create(:user, instruction_submit_notifications_for_api_entreprise: false) }

      it { is_expected.to be_falsey }
    end

    context 'when it sets to true' do
      let(:user) { create(:user, instruction_submit_notifications_for_api_entreprise: true) }

      it { is_expected.to be_truthy }
    end
  end
end
