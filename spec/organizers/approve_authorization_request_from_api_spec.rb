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

      context 'with an active approve webhook' do
        let!(:webhook) do
          create(:webhook, authorization_definition_id: 'api_scolarite', events: %w[approve], enabled: true, validated: true)
        end

        it 'tells the webhook that the approval comes from the API' do
          expect { approve_from_api }.to have_enqueued_job(DeliverAuthorizationRequestWebhookJob).with(
            webhook.id, authorization_request.id, 'approve', hash_including(source: 'api')
          )
        end
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

    context 'with a request which generates a linked FranceConnect authorization' do
      let(:authorization_request) do
        create(:authorization_request, :api_particulier_entrouvert_publik, :submitted, :with_france_connect_embedded_fields, fill_all_attributes: true)
      end
      let!(:instructor) { create(:user, :instructor, authorization_request_types: %w[api_particulier france_connect]) }

      it 'records the calling application on the generated event too' do
        approve_from_api

        expect(authorization_request.events.find_by(name: 'auto_generate').api_application_name).to eq('API Entreprise')
      end
    end

    context 'with a banned instructor' do
      before { instructor.update!(banned_at: Time.zone.now, ban_reason: 'Test') }

      it 'fails with the invalid instructor error' do
        expect(approve_from_api.error[:key]).to eq(:instructor_invalid)
      end

      it 'does not change the authorization request' do
        expect { approve_from_api }.not_to(change { authorization_request.reload.state })
      end
    end

    context 'when the transition fails after the authorizations were written' do
      before do
        allow_any_instance_of(AuthorizationRequest).to receive(:approve).and_return(false) # rubocop:disable RSpec/AnyInstance
      end

      it 'fails with the transition error' do
        expect(approve_from_api.error[:key]).to eq(:trigger_event_failed)
      end

      it 'rolls back the written authorizations' do
        expect { approve_from_api }.not_to(change(Authorization, :count))
      end

      it 'leaves the request submitted' do
        approve_from_api

        expect(authorization_request.reload.state).to eq('submitted')
      end
    end

    context 'when the request was already approved by a previous call' do
      before { described_class.call!(authorization_request:, instructor_email:, oauth_application:) }

      it 'fails with the not approvable error instead of creating another authorization' do
        expect { approve_from_api }.not_to(change(Authorization, :count))
        expect(approve_from_api.error[:key]).to eq(:not_approvable_from_api)
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
