RSpec.describe ApproveAuthorizationRequestFromAPI do
  describe '.call' do
    subject(:approve_from_api) do
      described_class.call(
        authorization_request:,
        instructor_email:,
        oauth_application:,
        authorization_message: 'Demande conforme'
      )
    end

    let(:oauth_application) { create(:oauth_application, name: 'API Entreprise') }
    let(:authorization_request) { create(:authorization_request, :api_scolarite, :submitted) }
    let!(:instructor) { create(:user, :instructor, authorization_request_types: %w[api_scolarite]) }
    let(:instructor_email) { instructor.email }

    context 'with a submitted request and a valid instructor' do
      it { is_expected.to be_success }

      it 'validates the authorization request' do
        expect { approve_from_api }.to change { authorization_request.reload.state }.from('submitted').to('validated')
      end

      it 'creates an active authorization' do
        expect { approve_from_api }.to change { authorization_request.authorizations.count }.by(1)
      end

      it 'records the instructor as author of the approve event' do
        approve_from_api

        expect(authorization_request.events.find_by(name: 'approve').user).to eq(instructor)
      end

      it 'records the calling application on the approve event' do
        approve_from_api

        expect(authorization_request.events.find_by(name: 'approve').api_application_name).to eq('API Entreprise')
      end
    end

    context 'without instructor email' do
      let(:instructor_email) { nil }

      it { is_expected.to be_failure }

      it 'fails with the invalid instructor error' do
        expect(approve_from_api.error[:key]).to eq(:instructor_invalid)
      end

      it 'does not change the authorization request' do
        expect { approve_from_api }.not_to(change { authorization_request.reload.state })
      end
    end

    context 'with an email which does not match any account' do
      let(:instructor_email) { 'inconnu@gouv.fr' }

      it 'fails with the invalid instructor error' do
        expect(approve_from_api.error[:key]).to eq(:instructor_invalid)
      end
    end

    context 'with an account which is not instructor for this type' do
      let!(:instructor) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }

      it 'fails with the invalid instructor error' do
        expect(approve_from_api.error[:key]).to eq(:instructor_invalid)
      end

      it 'does not change the authorization request' do
        expect { approve_from_api }.not_to(change { authorization_request.reload.state })
      end
    end

    %i[draft changes_requested refused validated].each do |state|
      context "with a request in #{state} state" do
        let(:authorization_request) { create(:authorization_request, :api_scolarite, state) }

        it 'fails with the not approvable error' do
          expect(approve_from_api.error[:key]).to eq(:not_approvable_from_api)
        end

        it 'does not change the state' do
          expect { approve_from_api }.not_to(change { authorization_request.reload.state })
        end
      end
    end
  end
end
