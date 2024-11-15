RSpec.describe Authorization do
  it 'has valid factories' do
    expect(build(:authorization)).to be_valid
  end

  describe '#request_as_validated' do
    subject(:request_as_validated) { authorization.request_as_validated }

    let!(:authorization) { authorization_request.latest_authorization }
    let!(:authorization_request) { create(:authorization_request, authorization_definition_kind, :validated, intitule: 'old intitule', maquette_projet: Rack::Test::UploadedFile.new('spec/fixtures/dummy.pdf', 'application/pdf')) }
    let(:authorization_definition_kind) { :api_entreprise }

    it { expect(request_as_validated).to be_a(AuthorizationRequest::APIEntreprise) }

    context 'when linked request is not longer the same type (because of the stage)' do
      let(:authorization_definition_kind) { :api_impot_particulier }

      before do
        authorization.update!(authorization_request_class: 'AuthorizationRequest::APIImpotParticulierSandbox')
      end

      it { expect(request_as_validated).to be_a(AuthorizationRequest::APIImpotParticulierSandbox) }
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
            maquette_projet: Rack::Test::UploadedFile.new('spec/fixtures/another_dummy.pdf', 'application/pdf')
          )
        )
        raise "UpdateAuthorizationRequest failed: #{organizer.error}" unless organizer.success?
      end

      it { expect(request_as_validated.id).to eq(authorization.request.id) }
      it { expect(request_as_validated.state).to eq('validated') }

      it 'does not update data nor document' do
        expect(request_as_validated.intitule).to eq('old intitule')
        expect(request_as_validated.maquette_projet).to be_attached
        expect(request_as_validated.maquette_projet.filename).to eq('dummy.pdf')
      end

      it 'does not restore the new document on request' do
        expect(authorization_request.reload.maquette_projet.filename).to eq('another_dummy.pdf')
      end
    end
  end
end
