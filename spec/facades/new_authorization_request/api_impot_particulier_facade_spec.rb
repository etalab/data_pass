RSpec.describe NewAuthorizationRequest::APIImpotParticulierFacade do
  describe '.public_available_forms_sandbox' do
    subject(:public_available_forms_sandbox) { instance.public_available_forms_sandbox }

    let(:instance) { described_class.new(authorization_definition: 'api_impot_particulier') }

    it 'returns a list of all sandbox forms' do
      expect(public_available_forms_sandbox.count).to be > 0

      expect(public_available_forms_sandbox).to be_all do |form|
        form.is_a?(AuthorizationRequestFormDecorator)
      end
    end
  end
end
