require 'rails_helper'

RSpec.describe Admin::TransferAuthorizationRequest, type: :organizer do
  describe '.call' do
    subject(:transfer_request) { described_class.call(params) }

    let(:params) do
      {
        authorization_request_id:,
        new_organization_siret:,
        new_applicant_email:,
        user:
      }
    end

    let(:user) { create(:user) }

    let(:authorization_request) { create(:authorization_request, :api_scolarite) }
    let(:authorization_request_id) { authorization_request.id }
    let(:organization) { create(:organization) }
    let(:new_organization_siret) { organization.legal_entity_id }
    let(:new_applicant) { create(:user, current_organization: organization) }
    let(:new_applicant_email) { new_applicant.email }

    context 'when all conditions are met' do
      it { is_expected.to be_success }

      it 'transfers the authorization request to the new organization' do
        expect { transfer_request }.to change { authorization_request.reload.organization }.to(organization)
      end

      it 'transfers the authorization request to the new applicant' do
        expect { transfer_request }.to change { authorization_request.reload.applicant }.to(new_applicant)
      end

      it 'creates an authorization request transfer' do
        expect { transfer_request }.to change(AuthorizationRequestTransfer, :count).by(1)
      end
    end

    context 'when authorization_request is not found' do
      let(:authorization_request_id) { 999_999 }

      it { is_expected.to be_failure }

      it 'returns authorization_request_not_found error' do
        expect(transfer_request.error).to eq(:authorization_request_not_found)
      end

      it 'does not create a transfer' do
        expect { transfer_request }.not_to change(AuthorizationRequestTransfer, :count)
      end
    end

    context 'when organization is not found' do
      let(:new_organization_siret) { '12345678901234' }

      it { is_expected.to be_failure }

      it 'returns new_organization_not_found error' do
        expect(transfer_request.error).to eq(:new_organization_not_found)
      end

      it 'does not create a transfer' do
        expect { transfer_request }.not_to change(AuthorizationRequestTransfer, :count)
      end
    end

    context 'when applicant is not found' do
      let(:new_applicant_email) { 'notfound@example.com' }

      it { is_expected.to be_failure }

      it 'returns new_applicant_not_found error' do
        expect(transfer_request.error).to eq(:new_applicant_not_found)
      end

      it 'does not create a transfer' do
        expect { transfer_request }.not_to change(AuthorizationRequestTransfer, :count)
      end
    end

    context 'when applicant does not belong to organization' do
      let(:new_applicant) { create(:user) }

      it { is_expected.to be_failure }

      it 'returns applicant_not_in_organization error' do
        expect(transfer_request.error).to eq(:applicant_not_in_organization)
      end

      it 'does not create a transfer' do
        expect { transfer_request }.not_to change(AuthorizationRequestTransfer, :count)
      end
    end

    context 'when email has uppercase letters' do
      let(:new_applicant_email) { new_applicant.email.upcase }

      it { is_expected.to be_success }

      it 'finds the applicant by downcased email' do
        expect(transfer_request.new_applicant).to eq(new_applicant)
      end
    end
  end
end
