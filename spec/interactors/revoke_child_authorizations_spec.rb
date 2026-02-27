require 'rails_helper'

RSpec.describe RevokeChildAuthorizations do
  describe '#call' do
    subject(:interactor) do
      described_class.call(
        authorization:,
        revocation_of_authorization_params: attributes_for(:revocation_of_authorization),
        user:
      )
    end

    let(:user) { create(:user, :instructor, authorization_request_types: %w[api_particulier]) }

    context 'when the authorization has an active child authorization' do
      let(:authorization_request) { create(:authorization_request, :api_particulier, :validated) }
      let(:authorization) { authorization_request.latest_authorization }
      let!(:child_authorization) do
        create(:authorization,
          request: authorization_request,
          applicant: authorization_request.applicant,
          authorization_request_class: 'AuthorizationRequest::FranceConnect',
          parent_authorization_id: authorization.id)
      end

      before do
        allow(RevokeAuthorization).to receive(:call!)
      end

      it { is_expected.to be_success }

      it 'calls RevokeAuthorization for the child authorization' do
        interactor

        expect(RevokeAuthorization).to have_received(:call!).with(
          authorization: child_authorization,
          revocation_of_authorization_params: anything,
          user:
        )
      end
    end

    context 'when the authorization has no child authorizations' do
      let(:authorization_request) { create(:authorization_request, :api_particulier, :validated) }
      let(:authorization) { authorization_request.latest_authorization }

      before do
        allow(RevokeAuthorization).to receive(:call!)
      end

      it { is_expected.to be_success }

      it 'does not call RevokeAuthorization' do
        interactor

        expect(RevokeAuthorization).not_to have_received(:call!)
      end
    end

    context 'when the authorization is auto-generated (recursion guard)' do
      let(:authorization_request) { create(:authorization_request, :api_particulier, :validated) }
      let(:parent_authorization) { authorization_request.latest_authorization }
      let(:authorization) do
        create(:authorization,
          request: authorization_request,
          applicant: authorization_request.applicant,
          authorization_request_class: 'AuthorizationRequest::FranceConnect',
          parent_authorization_id: parent_authorization.id)
      end

      before do
        allow(RevokeAuthorization).to receive(:call!)
      end

      it { is_expected.to be_success }

      it 'does not call RevokeAuthorization' do
        interactor

        expect(RevokeAuthorization).not_to have_received(:call!)
      end
    end
  end
end
