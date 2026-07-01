require 'rails_helper'

RSpec.describe AutoInstructAuthorizationRequest, type: :interactor do
  subject(:auto_instruct) { described_class.call(authorization_request:) }

  let(:authorization_request) do
    create(:authorization_request, :aide_financiere, :submitted, fill_all_attributes: true, organization:)
  end

  let(:organization) { create(:organization, siret:) }

  context 'when the organization is eligible (administration)' do
    let(:siret) { '21920023500014' }

    it 'auto-validates the request' do
      expect { auto_instruct }.to change { authorization_request.reload.state }.from('submitted').to('validated')
    end
  end

  context 'when the organization is ineligible' do
    let(:siret) { '38012986600006' }

    it 'auto-refuses the request with a reason' do
      auto_instruct

      expect(authorization_request.reload.state).to eq('refused')
      expect(authorization_request.denials.last.reason).to be_present
    end
  end

  context 'when the organization is in the gray zone (likely_eligible)' do
    let(:siret) { '55204944700006' }

    it 'leaves the request submitted for human review' do
      auto_instruct

      expect(authorization_request.reload.state).to eq('submitted')
    end
  end

  context 'when the demarche has no eligibility rule' do
    let(:authorization_request) do
      create(:authorization_request, :api_particulier, :submitted, fill_all_attributes: true, organization:)
    end
    let(:siret) { '21920023500014' }

    it 'does nothing' do
      auto_instruct

      expect(authorization_request.reload.state).to eq('submitted')
    end
  end

  context 'when the demarche opts in by convention (HubEE cert DC)' do
    let(:authorization_request) do
      create(:authorization_request, :hubee_cert_dc, :submitted, fill_all_attributes: true, organization:)
    end
    let(:siret) { '21920023500014' }

    it 'auto-validates a commune' do
      expect { auto_instruct }.to change { authorization_request.reload.state }.from('submitted').to('validated')
    end
  end

  context 'when a use-case-specific rule applies (API Entreprise — aides financières)' do
    let(:authorization_request) do
      create(:authorization_request, :api_entreprise_aides_financieres, :submitted, fill_all_attributes: true, organization:)
    end

    context 'with an administration' do
      let(:siret) { '21920023500014' }

      it 'auto-validates the request' do
        expect { auto_instruct }.to change { authorization_request.reload.state }.from('submitted').to('validated')
      end
    end

    context 'with a private company' do
      let(:siret) { '38012986600006' }

      it 'auto-refuses the request' do
        auto_instruct

        expect(authorization_request.reload.state).to eq('refused')
      end
    end
  end
end
