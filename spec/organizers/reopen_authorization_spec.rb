RSpec.describe ReopenAuthorization do
  describe '.call' do
    subject(:reopen_authorization_request) { described_class.call(authorization:, user:) }

    let(:user) { authorization_request.applicant }
    let(:authorization) { create(:authorization, request: authorization_request) }

    before do
      freeze_time
    end

    context 'with authorization request is in validated state' do
      let!(:authorization_request) { create(:authorization_request, authorization_request_kind, :validated) }
      let(:authorization_request_kind) { :api_entreprise }

      it { is_expected.to be_success }

      it 'changes state to draft' do
        expect { reopen_authorization_request }.to change { authorization_request.reload.state }.from('validated').to('draft')
      end

      it 'updates reopened_at to now' do
        expect { reopen_authorization_request }.to change { authorization_request.reload.reopened_at.try(:to_i) }.from(nil).to(Time.zone.now.to_i)
      end

      include_examples 'creates an event', event_name: :reopen, entity_type: :authorization
      include_examples 'delivers a webhook', event_name: :reopen
    end

    context 'with authorization request in draft state' do
      let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :draft) }

      it { is_expected.to be_failure }

      it 'does not change state' do
        expect { reopen_authorization_request }.not_to change { authorization_request.reload.state }
      end
    end

    context 'with an authorization_request_class to transition to' do
      subject(:reopen_authorization_request) { described_class.call(authorization:, user:, authorization_request_class:) }

      let(:authorization_request) { create(:authorization_request, :api_impot_particulier, :validated) }
      let(:authorization_request_class) { AuthorizationRequest::APIImpotParticulierSandbox }

      it 'transitions the authorization request to a previous stage' do
        expect { reopen_authorization_request }.to change { AuthorizationRequest.find(authorization_request.id).class }.from(AuthorizationRequest::APIImpotParticulier).to(AuthorizationRequest::APIImpotParticulierSandbox)
      end

      it "transistions the authorization request's form to the previous stage's form" do
        expect { reopen_authorization_request }.to change { AuthorizationRequest.find(authorization_request.id).form_uid }.from('api-impot-particulier-production').to('api-impot-particulier-sandbox')
      end

      context 'when the authorization_request_class is from the same stage' do
        let(:authorization_request_class) { AuthorizationRequest::APIImpotParticulier }

        it "doesn't transitions the authorization_request class" do
          expect { reopen_authorization_request }.not_to change { AuthorizationRequest.find(authorization_request.id).class }
        end

        it "doesn't transitions the authorization_request form" do
          expect { reopen_authorization_request }.not_to change { AuthorizationRequest.find(authorization_request.id).form_uid }
        end
      end

      context 'when the authorization_request_class is not an available reopen class' do
        let(:authorization_request_class) { AuthorizationRequest::APIHermes }

        it { is_expected.to be_failure }
      end
    end
  end
end
