RSpec.describe AuthorizationRequest do
  def all_form_uids
    AuthorizationRequestForm.all.map { |form| form.uid.underscore }
  end

  def state_machine_state_names
    AuthorizationRequest.state_machine.states.map(&:name)
  end

  describe 'Authorization Request has valid factories' do
    it 'has valid factories for all states and all form_uids' do
      all_form_uids.each do |form_uid|
        state_machine_state_names.each { |state_name| expect(build(:authorization_request, form_uid.to_sym, state_name)).to be_valid }
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
end
