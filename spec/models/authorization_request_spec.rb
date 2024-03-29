RSpec.describe AuthorizationRequest do
  describe 'factories' do
    it 'has valid factories for all states and all form_uids' do
      AuthorizationRequestForm.all.each do |form|
        AuthorizationRequest.state_machine.states.map(&:name).each do |state_name|
          expect(build(:authorization_request, form.uid.underscore, state_name)).to be_valid
        end
      end
    end

    it 'saves the authorization request with state submitted and then changes it to draft' do
      authorization_request = build(:authorization_request, :api_entreprise, state: 'submitted')
      authorization_request.save!
      authorization_request.state = 'draft'
      authorization_request.save!

      expect(authorization_request.state).to eq('draft')
    end

    it 'has a valid reopened factory' do
      authorization_request = create(:authorization_request, :api_entreprise, :reopened)

      expect(authorization_request).to be_reopening
    end

    it 'has a validated factory which creates an authorization' do
      authorization_request = create(:authorization_request, :api_entreprise, :validated)

      expect(authorization_request).to be_validated
      expect(authorization_request.latest_authorization).to be_a(Authorization)
    end
  end

  describe '#contact_types_for' do
    subject { authorization_request.contact_types_for(user) }

    let(:user) { create(:user) }
    let(:authorization_request) { create(:authorization_request, data: { 'contact_test_email' => contact_email, 'contact_lol_email' => contact_email, 'whatever' => user.email }) }

    context 'when user is a valid contact' do
      let(:contact_email) { user.email }

      it { is_expected.to eq(%w[contact_test contact_lol]) }
    end

    context 'when user is not a valid contact' do
      let(:contact_email) { 'what@ever.fr' }

      it { is_expected.to eq([]) }
    end
  end

  describe 'archive event' do
    subject(:archive) { authorization_request.archive }

    let(:authorization_request) { create(:authorization_request, :api_entreprise, state: 'draft') }

    it 'archives the authorization request' do
      expect {
        archive
      }.to change { authorization_request.reload.state }.from('draft').to('archived')
    end
  end

  describe 'save context' do
    subject(:save_authorization_request) { authorization_request.save(context:) }

    context 'when context is not provided' do
      let(:context) { nil }

      context 'when authorization request is not entire filled' do
        let(:authorization_request) { build(:authorization_request, :api_entreprise) }

        it { is_expected.to be_truthy }
      end
    end

    context 'when context is `review`' do
      let(:context) { :review }

      context 'when authorization request is not entire filled' do
        let(:authorization_request) { build(:authorization_request, :api_entreprise) }

        it { is_expected.to be_falsey }
      end

      context 'when authorization request is entire filled without terms' do
        let(:authorization_request) { build(:authorization_request, :api_entreprise, fill_all_attributes: true) }

        before do
          authorization_request.update!(terms_of_service_accepted: false)
        end

        it { is_expected.to be_truthy }
      end
    end

    context 'when context is `submit`' do
      let(:context) { :submit }

      context 'when authorization request is not entire filled' do
        let(:authorization_request) { build(:authorization_request, :api_entreprise) }

        it { is_expected.to be_falsey }
      end

      context 'when authorization request is entire filled without terms' do
        let(:authorization_request) { build(:authorization_request, :api_entreprise, fill_all_attributes: true) }

        before do
          authorization_request.update!(terms_of_service_accepted: false)
        end

        it { is_expected.to be_falsey }
      end

      context 'when authorization request is entire filled with terms' do
        let(:authorization_request) { build(:authorization_request, :api_entreprise, fill_all_attributes: true) }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe 'contact email validation' do
    subject(:authorization_request) { build(:authorization_request, :api_entreprise, fill_all_attributes: true, contact_metier_email: email) }

    let(:email) { generate(:email) }
    let!(:verified_email) { create(:verified_email, email:, status: 'undeliverable', verified_at: 1.day.ago) }

    describe 'without validation context' do
      it { is_expected.to be_valid }
    end

    describe 'with submit validation context' do
      it { is_expected.not_to be_valid(:submit) }
    end
  end
end
