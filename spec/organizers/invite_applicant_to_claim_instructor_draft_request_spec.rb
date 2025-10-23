require 'rails_helper'

RSpec.describe InviteApplicantToClaimInstructorDraftRequest, type: :organizer do
  subject(:organizer) { described_class.call(params) }

  let(:params) do
    {
      instructor_draft_request:,
      applicant_email: 'john@example.com',
      organization_siret: '13002526500013',
      comment: 'Looking forward to your application!',
    }
  end

  let(:instructor) { create(:user, :instructor) }
  let!(:instructor_draft_request) do
    create(:instructor_draft_request, instructor:)
  end

  before do
    mock_insee_sirene_api_etablissement_valid(siret: '13002526500013')
  end

  context 'with valid params' do
    it { is_expected.to be_success }

    it 'affects the given comment to the draft' do
      expect {
        organizer
      }.to change { instructor_draft_request.reload.comment }.from(nil).to('Looking forward to your application!')
    end

    it 'finds or creates a user with the given email' do
      expect { organizer }.to change(User, :count).by(1)

      user = User.find_by(email: 'john@example.com')
      expect(user).to be_present
      expect(instructor_draft_request.reload.applicant).to eq(user)
    end

    it 'finds or creates an organization with the given SIRET' do
      expect { organizer }.to change(Organization, :count).by(1)

      organization = Organization.find_by(legal_entity_id: '13002526500013')
      expect(organization).to be_present
      expect(instructor_draft_request.reload.organization).to eq(organization)
    end

    it 'adds the user to the organization, mark the identity federator as unknown and verified false' do
      organizer

      user = User.find_by(email: 'john@example.com')
      organization = Organization.find_by(legal_entity_id: '13002526500013')

      expect(user.organizations).to include(organization)

      organizations_user = user.organizations_users.find_by(organization:)

      expect(organizations_user.verified).to be_falsey
      expect(organizations_user.identity_federator).to eq('unknown')
    end

    it 'regenerates the public_id' do
      expect {
        organizer
      }.to change { instructor_draft_request.reload.public_id }
    end

    it 'sends an email' do
      ActiveJob::Base.queue_adapter = :inline

      expect {
        organizer
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      ActiveJob::Base.queue_adapter = :test

      mail = ActionMailer::Base.deliveries.last

      expect(mail.to).to eq(['john@example.com'])
      expect(mail.subject).to include(instructor_draft_request.project_name)
    end

    context 'when user already exists' do
      let!(:existing_user) { create(:user, email: 'john@example.com') }

      it 'does not create a new user' do
        expect { organizer }.not_to change(User, :count)

        expect(instructor_draft_request.reload.applicant).to eq(existing_user)
      end
    end

    context 'when organization already exists' do
      let!(:existing_organization) do
        create(:organization, legal_entity_id: '13002526500013', legal_entity_registry: 'insee_sirene')
      end

      it 'does not create a new organization' do
        expect { organizer }.not_to change(Organization, :count)

        expect(instructor_draft_request.reload.organization).to eq(existing_organization)
      end
    end
  end
end
