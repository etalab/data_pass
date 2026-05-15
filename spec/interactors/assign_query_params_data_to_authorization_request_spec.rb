require 'rails_helper'

RSpec.describe AssignQueryParamsDataToAuthorizationRequest do
  describe '#call' do
    subject(:interactor) { described_class.call(authorization_request:, prefill_data:) }

    let(:authorization_request) { build(:authorization_request, :api_particulier) }

    context 'when prefill_data is nil' do
      let(:prefill_data) { nil }

      it { is_expected.to be_success }

      it 'does not assign anything' do
        expect { interactor }.not_to change(authorization_request, :intitule)
      end
    end

    context 'when prefill_data is empty' do
      let(:prefill_data) { {} }

      it { is_expected.to be_success }
    end

    context 'with a string attribute declared via add_attributes' do
      let(:prefill_data) { { 'intitule' => 'Mon super projet' } }

      it 'assigns it on the authorization request' do
        interactor

        expect(authorization_request.intitule).to eq('Mon super projet')
      end
    end

    context 'with an array attribute' do
      let(:prefill_data) { { 'modalities' => %w[france_connect params] } }

      it 'assigns it on the authorization request' do
        interactor

        expect(authorization_request.modalities).to match_array(%w[france_connect params])
      end
    end

    context 'with scopes' do
      let(:prefill_data) { { 'scopes' => %w[cnaf_quotient_familial cnaf_allocataires] } }

      it 'assigns scopes on the authorization request' do
        interactor

        expect(authorization_request.scopes).to match_array(%w[cnaf_quotient_familial cnaf_allocataires])
      end
    end

    context 'with scopes on a request that does not support them' do
      let(:authorization_request) { build(:authorization_request, :api_captchetat) }
      let(:prefill_data) { { 'scopes' => %w[whatever] } }

      it 'ignores them' do
        interactor

        expect(authorization_request.data['scopes']).to be_nil
      end
    end

    context 'with a boolean attribute (checkbox)' do
      let(:authorization_request) { build(:authorization_request, :api_ficoba_sandbox) }
      let(:prefill_data) { { 'dpd_homologation_checkbox' => '1' } }

      it 'assigns it on the authorization request' do
        interactor

        expect(authorization_request.dpd_homologation_checkbox).to be(true)
      end
    end

    context 'with a key that is not prefillable' do
      let(:prefill_data) { { 'contact_technique_email' => 'attacker@evil.com', 'unknown_field' => 'foo' } }

      it 'ignores the unknown keys' do
        interactor

        expect(authorization_request.contact_technique_email).to be_nil
      end
    end

    context 'when default data was already assigned' do
      let(:prefill_data) { { 'intitule' => 'Depuis query param' } }

      before do
        authorization_request.intitule = 'Depuis initialize_with'
      end

      it 'overwrites the default data' do
        interactor

        expect(authorization_request.intitule).to eq('Depuis query param')
      end
    end

    context 'with a value whose setter raises' do
      let(:prefill_data) { { 'modalities' => 'not-an-array', 'intitule' => 'still works' } }

      it 'skips the offending attribute and keeps assigning the others' do
        interactor

        expect(authorization_request.intitule).to eq('still works')
      end
    end
  end
end
