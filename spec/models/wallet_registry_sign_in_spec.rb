RSpec.describe WalletRegistrySignIn do
  subject(:sign_in) { described_class.new(answer:, violation:, signed_in:, organization:, return_to: '/formulaires/registre-wallet/demande/nouveau') }

  let(:answer) { nil }
  let(:violation) { nil }
  let(:signed_in) { false }
  let(:organization) { nil }
  let(:executive_journey_open) { true }

  before do
    allow(FeatureFlag).to receive(:enabled?).and_call_original
    allow(FeatureFlag).to receive(:enabled?).with(:proconnect_dirigeant).and_return(executive_journey_open)
  end

  context 'when a signed out visitor answered agent' do
    let(:answer) { 'agent' }

    it 'gives the usual ProConnect button' do
      expect(sign_in.pro_connect_locals).to eq(return_to: '/formulaires/registre-wallet/demande/nouveau', title: nil, wrapper_class: nil)
    end
  end

  context 'when a signed out visitor answered dirigeant' do
    let(:answer) { 'dirigeant' }

    it 'opens the executive journey from the usual ProConnect button' do
      expect(sign_in.pro_connect_locals).to include(hidden_fields: { parcours: 'dirigeant' })
      expect(sign_in.answer_key).to eq('dirigeant')
    end

    context 'when the executive journey is closed' do
      let(:executive_journey_open) { false }

      it 'gives the usual button and does not promise the certification' do
        expect(sign_in.pro_connect_locals).not_to have_key(:hidden_fields)
        expect(sign_in.answer_key).to eq('dirigeant_without_certification')
      end
    end
  end

  context 'when a signed in member of a company without certification has no answer' do
    let(:signed_in) { true }
    let(:violation) { :executive_certification_required }
    let(:organization) { build(:organization, siret: '32816124500027') }

    it 'offers the executive certification of the organization of the connection' do
      expect(sign_in.pro_connect_locals).to include(identity_federator: 'proconnect_dirigeant', hidden_fields: { siret_hint: '32816124500027' })
    end

    context 'when the executive journey is closed' do
      let(:executive_journey_open) { false }

      it 'gives the usual button' do
        expect(sign_in.pro_connect_locals).not_to have_key(:identity_federator)
      end
    end
  end
end
