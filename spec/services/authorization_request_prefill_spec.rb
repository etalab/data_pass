RSpec.describe AuthorizationRequestPrefill do
  subject(:prefill) { described_class.new(session, AuthorizationRequestForm.find('api-particulier')) }

  let(:session) { {} }

  describe '#capture' do
    it 'keeps only the prefillable attributes, scoped by form' do
      prefill.capture('intitule' => 'Mon projet', 'not_an_attribute' => 'noise')

      expect(session[:authorization_request_prefill]).to eq('form_uid' => 'api-particulier', 'data' => { 'intitule' => 'Mon projet' })
    end

    it 'forgets the previous prefill of the form when no attribute matches' do
      prefill.capture('intitule' => 'Premier passage')
      prefill.capture('not_an_attribute' => 'noise')

      expect(session[:authorization_request_prefill]).to be_nil
    end
  end

  describe '#data' do
    it 'returns the captured attributes of the form' do
      prefill.capture('intitule' => 'Mon projet')

      expect(prefill.data).to eq('intitule' => 'Mon projet')
    end

    it 'ignores the prefill of another form' do
      described_class.new(session, AuthorizationRequestForm.find('api-entreprise-socle-de-base')).capture('intitule' => 'Autre')

      expect(prefill.data).to be_nil
    end
  end

  describe '#clear' do
    it 'leaves the prefill of another form untouched' do
      described_class.new(session, AuthorizationRequestForm.find('api-entreprise-socle-de-base')).capture('intitule' => 'Autre')

      prefill.clear

      expect(session[:authorization_request_prefill]).to include('form_uid' => 'api-entreprise-socle-de-base')
    end
  end
end
