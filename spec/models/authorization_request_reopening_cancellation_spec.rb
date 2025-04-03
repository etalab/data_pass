RSpec.describe AuthorizationRequestReopeningCancellation do
  it 'has valid factories' do
    expect(build(:authorization_request_reopening_cancellation)).to be_valid
    expect(build(:authorization_request_reopening_cancellation, :from_instructor)).to be_valid
  end

  describe 'user validation' do
    context 'when user is the applicant' do
      subject { build(:authorization_request_reopening_cancellation, request:, user:) }

      let(:user) { create(:user) }
      let(:request) { create(:authorization_request, applicant: user) }

      it { is_expected.to be_valid }
    end

    context 'when user is an instructor' do
      subject { build(:authorization_request_reopening_cancellation, :from_instructor, request:, user:) }

      let(:user) { create(:user, :instructor, authorization_request_types: ['api_entreprise']) }
      let(:request) { create(:authorization_request, :api_entreprise) }

      it { is_expected.to be_valid }
    end

    context 'when user is not the applicant nor an instructor' do
      subject { build(:authorization_request_reopening_cancellation, request:, user:) }

      let(:user) { create(:user) }
      let(:request) { create(:authorization_request) }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'reason validation' do
    context 'when it is from instructor' do
      subject { build(:authorization_request_reopening_cancellation, :from_instructor, reason:) }

      context 'when reason is blank' do
        let(:reason) { '' }

        it { is_expected.not_to be_valid }
      end

      context 'when reason is present' do
        let(:reason) { 'reason' }

        it { is_expected.to be_valid }
      end
    end

    context 'when it is from applicant' do
      subject { build(:authorization_request_reopening_cancellation, :from_applicant, reason:) }

      context 'when reason is blank' do
        let(:reason) { '' }

        it { is_expected.to be_valid }
      end
    end
  end
end
