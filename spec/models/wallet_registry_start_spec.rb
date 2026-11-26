RSpec.describe WalletRegistryStart do
  subject(:start) { described_class.new(answer:, violation:, verification:, organization:, signed_in:) }

  let(:return_to) { '/demandes/registre_wallet/nouveau' }
  let(:answer) { nil }
  let(:violation) { nil }
  let(:verification) { nil }
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
      expect(start.pro_connect_locals(return_to:)).to eq(return_to:, title: nil, wrapper_class: nil)
    end

    it 'refuses nothing before the sign in' do
      expect(start.refusal).to be_nil
    end
  end

  context 'when a signed out visitor gives an answer that the tree does not offer' do
    let(:answer) { 'admin' }

    it 'forgets the answer' do
      expect(start.answer).to be_nil
    end
  end

  context 'when a signed out visitor answered dirigeant' do
    let(:answer) { 'dirigeant' }

    it 'opens the executive journey from the usual ProConnect button' do
      expect(start.pro_connect_locals(return_to:)).to include(hidden_fields: { parcours: 'dirigeant' })
      expect(start.answer_key).to eq('dirigeant')
    end

    context 'when the executive journey is closed' do
      let(:executive_journey_open) { false }

      it 'gives the usual button and does not promise the certification' do
        expect(start.pro_connect_locals(return_to:)).not_to have_key(:hidden_fields)
        expect(start.answer_key).to eq('dirigeant_without_certification')
      end
    end
  end

  context 'when a signed in member of a company without certification has no answer' do
    let(:signed_in) { true }
    let(:violation) { :executive_certification_required }
    let(:organization) { build(:organization, siret: '32816124500027') }

    it 'offers the executive certification of the organization of the connection' do
      expect(start.pro_connect_locals(return_to:)).to include(identity_federator: 'proconnect_dirigeant', hidden_fields: { siret_hint: '32816124500027' })
    end

    it 'explains that the certification is required' do
      expect(start.refusal).to eq(:executive_certification_required)
    end

    context 'when the executive journey is closed' do
      let(:executive_journey_open) { false }

      it 'gives the usual button and says the certification is unavailable' do
        expect(start.pro_connect_locals(return_to:)).not_to have_key(:identity_federator)
        expect(start.refusal).to eq(:executive_certification_unavailable)
      end
    end
  end

  context 'when the executive verification just failed' do
    let(:signed_in) { true }
    let(:violation) { :executive_certification_required }
    let(:verification) { { 'status' => 'failure', 'reason' => 'siret_outside_siren' } }

    it 'explains the failure rather than the missing certification' do
      expect(start.refusal).to eq(:executive_siret_outside_siren)
    end
  end

  context 'when the verification failed for an unknown reason' do
    let(:verification) { { 'status' => 'failure', 'reason' => 'unexpected' } }

    it 'gives the default refusal' do
      expect(start.refusal).to eq(:default)
    end
  end
end
