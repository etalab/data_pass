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
end
