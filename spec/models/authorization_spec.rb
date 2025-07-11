RSpec.describe Authorization do
  it 'has valid factories' do
    expect(build(:authorization)).to be_valid
  end

  describe 'state machine' do
    it { is_expected.to have_states :active, :obsolete, :revoked }
    it { is_expected.to handle_events :deprecate, :revoke, when: :active }
    it { is_expected.to handle_events :deprecate, :revoke, :rollback_revoke, when: :obsolete }
    it { is_expected.to handle_events :rollback_revoke, when: :revoked }

    describe 'transitions' do
      subject(:authorization) { build(:authorization) }

      it { is_expected.to transition_from :active, :obsolete, to_state: :obsolete, on_event: :deprecate }
      it { is_expected.to transition_from :active, to_state: :revoked, on_event: :revoke }
      it { is_expected.to transition_from :obsolete, to_state: :obsolete, on_event: :revoke }
      it { is_expected.to transition_from :revoked, to_state: :active, on_event: :rollback_revoke }
      it { is_expected.to transition_from :obsolete, to_state: :obsolete, on_event: :rollback_revoke }

      describe 'after_transitions' do
        describe 'revoke' do
          subject(:revoke) { authorization.revoke }

          it 'marks the authorization as revoked' do
            expect { revoke }.to change(authorization, :revoked).from(false).to(true)
          end
        end

        describe 'rollback_revoke' do
          subject(:rollback_revoke) { authorization.rollback_revoke }

          before do
            authorization.revoke!
          end

          it 'marks the authorization as not revoked' do
            expect { rollback_revoke }.to change(authorization, :revoked).from(true).to(false)
          end
        end
      end
    end

    # TODO : remove when the state machine is fully functional
    describe '#revoked?' do
      subject(:revoked) { authorization.revoked? }

      let(:authorization) { build(:authorization, revoked: revoked_attribute, state: state_attribute) }
      let(:revoked_attribute) { true }
      let(:state_attribute) { :revoked }

      context 'when not using the feature flag' do
        context 'when the revoked attribute is true' do
          let(:state_attribute) { :active }

          it { is_expected.to be true }
        end

        context 'when the revoked attribute is false' do
          let(:revoked_attribute) { false }

          it { is_expected.to be false }
        end
      end

      context 'when using the feature flag' do
        before do
          ENV['FEATURE_USE_AUTH_STATES'] = 'true'
        end

        after do
          ENV.delete('FEATURE_USE_AUTH_STATES')
        end

        context 'when the state is revoked' do
          let(:revoked_attribute) { false }

          it { is_expected.to be true }
        end

        context 'when the state is not revoked' do
          let(:state_attribute) { :active }

          it { is_expected.to be false }
        end
      end
    end
  end

  describe '#request_as_validated' do
    subject(:request_as_validated) { authorization.request_as_validated }

    let!(:authorization) { authorization_request.latest_authorization }
    let!(:authorization_request) { create(:authorization_request, authorization_definition_kind, :validated, intitule: 'old intitule', maquette_projet: [Rack::Test::UploadedFile.new('spec/fixtures/dummy.pdf', 'application/pdf')]) }
    let(:authorization_definition_kind) { :api_entreprise }

    it { expect(request_as_validated).to be_a(AuthorizationRequest::APIEntreprise) }

    context 'when linked request is not longer the same type (because of the stage)' do
      let(:authorization_definition_kind) { :api_impot_particulier }

      before do
        authorization.update!(authorization_request_class: 'AuthorizationRequest::APIImpotParticulierSandbox')
      end

      it { expect(request_as_validated).to be_a(AuthorizationRequest::APIImpotParticulierSandbox) }
    end

    context 'when revoked is true' do
      before do
        authorization.update!(revoked: true)
      end

      it 'has a revoked state' do
        expect(request_as_validated.state).to eq('revoked')
      end
    end

    context 'when request has been reopened, with some data changed and a document updated' do
      before do
        organizer = ReopenAuthorization.call(authorization:, user: authorization.applicant)
        raise "ReopenAuthorization failed: #{organizer.error}" unless organizer.success?

        organizer = UpdateAuthorizationRequest.call(
          authorization_request: authorization.request,
          user: authorization.request.applicant,
          authorization_request_params: ActionController::Parameters.new(
            intitule: 'new intitule',
            maquette_projet: [Rack::Test::UploadedFile.new('spec/fixtures/another_dummy.pdf', 'application/pdf')]
          )
        )
        raise "UpdateAuthorizationRequest failed: #{organizer.error}" unless organizer.success?
      end

      it { expect(request_as_validated.id).to eq(authorization.request.id) }
      it { expect(request_as_validated.state).to eq('validated') }

      it 'does not update data nor document' do
        expect(request_as_validated.intitule).to eq('old intitule')
        expect(request_as_validated.maquette_projet).to be_attached
        expect(request_as_validated.maquette_projet.first.filename.to_s).to eq('dummy.pdf')
      end

      it 'does not restore the new document on request' do
        expect(authorization_request.reload.maquette_projet.first.filename.to_s).to eq('another_dummy.pdf')
      end
    end
  end

  describe '#latest?' do
    subject { authorization.latest? }

    let!(:authorization) { authorization_request.latest_authorization }
    let!(:authorization_request) { create(:authorization_request, :validated) }

    it { is_expected.to be true }

    context 'when there is a newer authorization' do
      before do
        create(:authorization, request: authorization_request)
      end

      it { is_expected.to be false }
    end

    context 'when the definition has stages and the authorization is sandbox' do
      let!(:authorization_request) { create(:authorization_request, :api_impot_particulier_production, :validated) }
      let!(:authorization) { authorization_request.authorizations.order(created_at: :asc).first }

      context 'when a newer production authorization exists' do
        it { is_expected.to be true }
      end

      context 'when a newer sandbox authorization exists' do
        before do
          create(:authorization, request: authorization_request, authorization_request_class: authorization.authorization_request_class, created_at: Date.tomorrow)
        end

        it { is_expected.to be false }
      end
    end
  end

  describe '#approving_instructor' do
    subject { authorization.approving_instructor }

    let!(:authorization) { create(:authorization) }

    context 'when there is no approving instructor' do
      it { is_expected.to be_nil }
    end

    context 'when there is an approve event' do
      let!(:event) { create(:authorization_request_event, entity: authorization, name: 'approve') }

      it { is_expected.to eq(event.user) }
    end

    context 'when there is several approve events' do
      let!(:events) do
        create_list(:authorization_request_event, 3, entity: authorization, name: 'approve') do |event, index|
          event.update(created_at: Time.zone.now - index.days)
        end
      end

      it { is_expected.to eq(events.first.user) }
    end
  end
end
