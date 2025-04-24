RSpec.describe ReopenAuthorization do
  describe '.call' do
    subject(:reopen_authorization_request) { described_class.call(authorization:, user:) }

    let(:user) { authorization_request.applicant }

    before do
      freeze_time
    end

    context 'with authorization request is in validated state' do
      let!(:authorization_request) { create(:authorization_request, authorization_request_kind, :validated) }
      let(:authorization) { authorization_request.latest_authorization }
      let(:authorization_request_kind) { :api_entreprise }

      it { is_expected.to be_success }

      it 'changes state to draft' do
        expect { reopen_authorization_request }.to change { authorization_request.reload.state }.from('validated').to('draft')
      end

      it 'updates reopened_at to now' do
        expect { reopen_authorization_request }.to change { authorization_request.reload.reopened_at.try(:to_i) }.from(nil).to(Time.zone.now.to_i)
      end

      it_behaves_like 'creates an event', event_name: :reopen, entity_type: :authorization
      it_behaves_like 'delivers a webhook', event_name: :reopen
    end

    context 'with authorization request in draft state' do
      let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :draft) }
      let(:authorization) { create(:authorization, request: authorization_request) }

      it { is_expected.to be_failure }

      it 'does not change state' do
        expect { reopen_authorization_request }.not_to change { authorization_request.reload.state }
      end
    end

    context 'with an authorization of a different stage than the request' do
      let(:authorization_request) { create(:authorization_request, :api_impot_particulier, :validated) }
      let(:authorization) { authorization_request.latest_authorization_of_class 'AuthorizationRequest::APIImpotParticulierSandbox' }

      it "transitions the authorization request to the authorization's stage" do
        expect { reopen_authorization_request }.to change { AuthorizationRequest.find(authorization_request.id).class }.from(AuthorizationRequest::APIImpotParticulier).to(AuthorizationRequest::APIImpotParticulierSandbox)
      end

      it "transitions the authorization request's form to the authorization's form" do
        expect { reopen_authorization_request }.to change { AuthorizationRequest.find(authorization_request.id).form_uid }.from('api-impot-particulier-production').to('api-impot-particulier-sandbox')
      end

      context 'when the authorization_request is from the same stage as the authorisation' do
        let(:authorization) { authorization_request.latest_authorization_of_class 'AuthorizationRequest::APIImpotParticulier' }

        it "doesn't transitions the authorization_request class" do
          expect { reopen_authorization_request }.not_to change { AuthorizationRequest.find(authorization_request.id).class }
        end

        it "doesn't transitions the authorization_request form" do
          expect { reopen_authorization_request }.not_to change { AuthorizationRequest.find(authorization_request.id).form_uid }
        end
      end

      context 'when the authorization_request is not the last of its stage' do
        let(:authorization) { authorization_request.authorizations.first }
        let!(:more_recent_authorization) { create(:authorization, request: authorization_request, authorization_request_class: 'AuthorizationRequest::APIImpotParticulierSandbox', created_at: Date.tomorrow) }

        it { is_expected.to be_failure }
      end
    end
  end
end
