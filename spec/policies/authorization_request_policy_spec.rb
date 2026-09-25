RSpec.describe AuthorizationRequestPolicy do
  let(:instance) { described_class.new(user_context, authorization_request_class) }
  let(:user_context) { UserContext.new(user) }
  let(:user) { create(:user) }

  describe '#new?' do
    subject { instance.new? }

    describe 'HubEE' do
      let(:authorization_request_class) { AuthorizationRequest::HubEECertDC }

      context 'when there already is an authorization_request archived' do
        before { create(:authorization_request, :hubee_cert_dc, :archived, applicant: user) }

        it { is_expected.to be_truthy }
      end

      context 'when there already is another authorization_request not archived' do
        before { create(:authorization_request, :hubee_cert_dc, applicant: user) }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe '#create?' do
    subject { instance.create? }

    describe 'HubEE CertDC' do
      let(:authorization_request_class) { AuthorizationRequest::HubEECertDC }

      context 'when there already is an authorization_request archived' do
        before { create(:authorization_request, :hubee_cert_dc, :archived, applicant: user) }

        it { is_expected.to be_truthy }
      end

      context 'when there already is another authorization_request not archived' do
        before { create(:authorization_request, :hubee_cert_dc, applicant: user) }

        it { is_expected.to be_falsey }
      end

      context 'when there already is another authorization_request refused' do
        before { create(:authorization_request, :hubee_cert_dc, :refused, applicant: user) }

        it { is_expected.to be_truthy }
      end

      context 'when there already is another authorization_request revoked' do
        before { create(:authorization_request, :hubee_cert_dc, :revoked, applicant: user) }

        it { is_expected.to be_truthy }
      end
    end

    describe 'HubEE DILA' do
      let(:authorization_request_class) { AuthorizationRequest::HubEEDila }

      context 'when there already is an authorization_request archived' do
        before { create(:authorization_request, :hubee_dila, :archived, applicant: user) }

        it { is_expected.to be_truthy }
      end

      context 'when there already is another authorization_request not archived' do
        before { create(:authorization_request, :hubee_dila, applicant: user) }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#submit_reopening?' do
    subject { instance.submit_reopening? }

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated, applicant: user) }
    let(:authorization_request_class) { authorization_request }

    context 'when the user is from another organization' do
      let(:another_user) { create(:user) }
      let(:user_context) { UserContext.new(another_user) }

      it { is_expected.to be false }
    end

    context 'when the user is from the same organization' do
      context 'when data has not changed' do
        it { is_expected.to be false }
      end

      context 'when data has changed' do
        before do
          authorization_request.data['intitule'] = 'Meilleur titre'
        end

        it { is_expected.to be true }
      end

      context 'when the latest approval predates an attribute added to the form since' do
        let(:authorization_request) { create(:authorization_request, :api_ficoba_sandbox, :validated, applicant: user) }
        let(:attributes_added_since) { %w[adresse_ip_publique contact_technique_adresse contact_technique_adresse_complement] }

        before do
          authorization = authorization_request.latest_authorization
          authorization.update!(data: authorization.data.except(*attributes_added_since))
          authorization_request.data = authorization_request.data.except(*attributes_added_since)
        end

        context 'when the applicant fills it in' do
          before { authorization_request.data['adresse_ip_publique'] = '198.51.100.24' }

          it { is_expected.to be true }
        end

        context 'when the applicant only saves it blank' do
          before { authorization_request.data['contact_technique_adresse_complement'] = '' }

          it { is_expected.to be false }
        end
      end

      context 'when only documents differ from the latest approval' do
        let(:authorization_request) { create(:authorization_request, :api_ficoba_sandbox, :validated, applicant: user) }
        let(:attach_maquette!) do
          authorization_request.maquette_projet.attach(io: Rails.root.join('spec/fixtures/dummy.pdf').open, filename: 'dummy.pdf')
        end

        context 'when a document has been added since' do
          before { attach_maquette! }

          it { is_expected.to be true }
        end

        context 'when a document approved has been removed since' do
          before do
            attach_maquette!
            snapshot = authorization_request.latest_authorization.documents.create!(identifier: 'maquette_projet')
            snapshot.files.attach(authorization_request.maquette_projet.attachments.last.blob)
            authorization_request.maquette_projet.attachments.last.destroy!
            authorization_request.reload
          end

          it { is_expected.to be true }
        end

        context 'when documents are the ones approved' do
          before do
            attach_maquette!
            snapshot = authorization_request.latest_authorization.documents.create!(identifier: 'maquette_projet')
            snapshot.files.attach(authorization_request.maquette_projet.attachments.last.blob)
          end

          it { is_expected.to be false }
        end
      end

      context 'when the request still holds data of the next stage' do
        let(:authorization_request) { create(:authorization_request, :api_ficoba_sandbox, :validated, applicant: user) }

        before { authorization_request.data['safety_certification_authority_name'] = 'Jean Dupont' }

        it { is_expected.to be false }
      end
    end
  end

  describe '#manual_transfer?' do
    subject { instance.manual_transfer_from_instructor? }

    context 'with a DGFIP draft production (non-regression test)' do
      let(:authorization_request) { create(:authorization_request, :api_impot_particulier_production, :draft, applicant: user) }
      let(:authorization_request_class) { authorization_request }

      it { is_expected.to be true }
    end
  end

  describe '#reopen?' do
    subject { instance.reopen? }

    let(:authorization_request_class) { authorization_request }

    context 'when there are no authorizations' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, applicant: user) }

      it { is_expected.to be false }
    end

    context 'when there is at least one authorization' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated, applicant: user) }

      context 'when reopening feature is disabled' do
        before do
          allow(authorization_request.definition).to receive(:feature?).with(:reopening).and_return(false)
        end

        it { is_expected.to be false }
      end

      context 'when user is not the applicant or not from the same organization' do
        let(:another_user) { create(:user) }
        let(:user_context) { UserContext.new(another_user) }

        it { is_expected.to be false }
      end

      context 'when user is the request applicant, from the same organization but not authorization applicant' do
        let(:another_user) { create(:user) }
        let(:user_context) { UserContext.new(another_user) }

        before do
          another_user.add_to_organization(authorization_request.organization, verified: true, current: true)
          authorization_request.update!(applicant: another_user)
        end

        it { is_expected.to be true }
      end

      context 'when authorization is not reopenable' do
        context 'when authorization is not active' do
          before do
            authorization_request.latest_authorization.update!(state: 'revoked')
          end

          it { is_expected.to be false }
        end

        context 'when request is currently being reopened' do
          before do
            authorization_request.update!(reopened_at: 1.hour.ago, state: 'draft')
          end

          it { is_expected.to be false }
        end
      end

      context 'when all conditions are met' do
        it { is_expected.to be true }
      end

      context 'with multiple authorizations where one is reopenable' do
        before do
          create(:authorization, request: authorization_request, authorization_request_class: authorization_request.type, state: 'revoked', created_at: 1.day.ago)
        end

        it { is_expected.to be true }
      end
    end
  end

  describe '#events?' do
    subject { instance.events? }

    let(:authorization_request_class) { authorization_request }
    let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted, applicant: user) }

    context 'when user is the applicant' do
      it { is_expected.to be true }
    end

    context 'when user is a verified organization member' do
      let(:org_member) { create(:user) }
      let(:user_context) { UserContext.new(org_member) }

      before do
        org_member.add_to_organization(authorization_request.organization, verified: true, current: true)
      end

      it { is_expected.to be true }
    end

    context 'when user is a reporter for the authorization type' do
      let(:reporter) { create(:user, :reporter, authorization_request_types: %i[api_entreprise]) }
      let(:user_context) { UserContext.new(reporter) }

      it { is_expected.to be true }
    end

    context 'when user is a designated contact' do
      let(:contact_user) { create(:user) }
      let(:user_context) { UserContext.new(contact_user) }

      before do
        authorization_request.update!(data: authorization_request.data.merge('contact_metier_email' => contact_user.email))
      end

      it { is_expected.to be false }
    end

    context 'when user has no relation to the request' do
      let(:random_user) { create(:user) }
      let(:user_context) { UserContext.new(random_user) }

      it { is_expected.to be false }
    end
  end

  describe '#messages?' do
    subject { instance.messages? }

    let(:authorization_request_class) { authorization_request }
    let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted, applicant: user) }

    context 'when user is the applicant' do
      it { is_expected.to be true }
    end

    context 'when user is a verified organization member' do
      let(:org_member) { create(:user) }
      let(:user_context) { UserContext.new(org_member) }

      before do
        org_member.add_to_organization(authorization_request.organization, verified: true, current: true)
      end

      it { is_expected.to be true }
    end

    context 'when user is a reporter for the authorization type' do
      let(:reporter) { create(:user, :reporter, authorization_request_types: %i[api_entreprise]) }
      let(:user_context) { UserContext.new(reporter) }

      it { is_expected.to be true }
    end

    context 'when user is a designated contact' do
      let(:contact_user) { create(:user) }
      let(:user_context) { UserContext.new(contact_user) }

      before do
        authorization_request.update!(data: authorization_request.data.merge('contact_metier_email' => contact_user.email))
      end

      it { is_expected.to be false }
    end

    context 'when messaging feature is disabled' do
      before do
        allow(authorization_request.definition).to receive(:feature?).with(:messaging).and_return(false)
      end

      it { is_expected.to be false }
    end
  end

  describe '#send_message?' do
    subject { instance.send_message? }

    let(:authorization_request_class) { authorization_request }
    let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted, applicant: user) }

    context 'when user is the applicant' do
      it { is_expected.to be true }
    end

    context 'when user is a verified organization member but not the applicant' do
      let(:org_member) { create(:user) }
      let(:user_context) { UserContext.new(org_member) }

      before do
        org_member.add_to_organization(authorization_request.organization, verified: true, current: true)
      end

      it { is_expected.to be false }
    end

    context 'when user is a reporter for the authorization type' do
      let(:reporter) { create(:user, :reporter, authorization_request_types: %i[api_entreprise]) }
      let(:user_context) { UserContext.new(reporter) }

      it { is_expected.to be false }
    end
  end

  describe '#authorizations?' do
    subject { instance.authorizations? }

    let(:authorization_request_class) { authorization_request }
    let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted, applicant: user) }

    context 'when user is the applicant' do
      it { is_expected.to be true }
    end

    context 'when user is a verified organization member' do
      let(:org_member) { create(:user) }
      let(:user_context) { UserContext.new(org_member) }

      before do
        org_member.add_to_organization(authorization_request.organization, verified: true, current: true)
      end

      it { is_expected.to be true }
    end

    context 'when user is a reporter for the authorization type' do
      let(:reporter) { create(:user, :reporter, authorization_request_types: %i[api_entreprise]) }
      let(:user_context) { UserContext.new(reporter) }

      it { is_expected.to be true }
    end

    context 'when user is a designated contact' do
      let(:contact_user) { create(:user) }
      let(:user_context) { UserContext.new(contact_user) }

      before do
        authorization_request.update!(data: authorization_request.data.merge('contact_metier_email' => contact_user.email))
      end

      it { is_expected.to be false }
    end
  end

  describe '#france_connected_authorizations?' do
    subject { instance.france_connected_authorizations? }

    let(:authorization_request_class) { authorization_request }

    context 'when not a france_connect request without FC link' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted, applicant: user) }

      it { is_expected.to be false }
    end

    context 'when non-FC request with linked FC authorizations by france_connect_authorization_id' do
      let(:fc_authorization_request) { create(:authorization_request, :france_connect, :validated, applicant: user) }
      let(:authorization_request) do
        create(:authorization_request, :api_droits_cnam, :validated, applicant: user).tap do |ar|
          ar.update!(data: ar.data.merge('france_connect_authorization_id' => fc_authorization_request.latest_authorization.id.to_s))
        end
      end

      it { is_expected.to be false }
    end

    context 'when non-FC request with auto-generated FC child authorization' do
      let(:authorization_request) { create(:authorization_request, :api_particulier, :validated, applicant: user) }

      before do
        fc_auth = create(:authorization,
          request: authorization_request,
          authorization_request_class: 'AuthorizationRequest::FranceConnect',
          parent_authorization_id: authorization_request.latest_authorization.id)
        link_fc_authorization_to_request(authorization_request, fc_auth)
      end

      it { is_expected.to be true }
    end

    context 'when france_connect request without referencing authorizations' do
      let(:authorization_request) { create(:authorization_request, :france_connect, :validated, applicant: user) }

      it { is_expected.to be false }
    end

    context 'when france_connect request with referencing authorizations' do
      let(:authorization_request) { create(:authorization_request, :france_connect, :validated, applicant: user) }

      before do
        api_request = create(:authorization_request, :api_droits_cnam, :validated, applicant: user)
        link_fc_authorization_to_request(api_request, authorization_request.latest_authorization)
      end

      it { is_expected.to be true }
    end

    context 'when user does not have summary access' do
      let(:authorization_request) { create(:authorization_request, :api_particulier, :validated, applicant: user) }
      let(:another_user) { create(:user) }
      let(:user_context) { UserContext.new(another_user) }

      before do
        fc_auth = create(:authorization,
          request: authorization_request,
          authorization_request_class: 'AuthorizationRequest::FranceConnect',
          parent_authorization_id: authorization_request.latest_authorization.id)
        link_fc_authorization_to_request(authorization_request, fc_auth)
      end

      it { is_expected.to be false }
    end
  end
end
