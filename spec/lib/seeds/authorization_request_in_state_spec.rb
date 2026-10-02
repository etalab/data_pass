RSpec.describe Seeds::AuthorizationRequestInState do
  subject(:requests) { described_class.new(seeds) }

  let(:seeds) { Seeds.new }

  before do
    seeds.create_data_providers
    seeds.send(:create_test_accounts)
  end

  it 'creates a draft request for the reference applicant by default' do
    authorization_request = requests.create_draft_authorization_request(:api_entreprise)

    expect(authorization_request).to have_attributes(state: 'draft', applicant: seeds.dem_commune)
    expect(authorization_request.description).to be_present
  end

  it 'leaves out the description for request types without one' do
    authorization_request = requests.create_submitted_authorization_request(:api_mobilic)

    expect(authorization_request.state).to eq('submitted')
  end

  {
    create_validated_authorization_request: 'validated',
    create_refused_authorization_request: 'refused',
    create_revoked_authorization_request: 'revoked',
    create_request_changes_authorization_request: 'changes_requested',
  }.each do |creation, state|
    it "#{creation} leaves the request #{state}, instructed by an instructor of its type" do
      authorization_request = requests.public_send(creation, :api_impot_particulier_sandbox)
      instruction_event = authorization_request.events.where.not(name: %w[create update submit]).last

      expect(authorization_request.reload.state).to eq(state)
      expect(instruction_event.user).to be_instructor('api_impot_particulier_sandbox')
    end
  end

  it 'creates a reopened request in draft' do
    authorization_request = requests.create_reopened_authorization_request(:api_entreprise)

    expect(authorization_request.reload).to have_attributes(state: 'draft', reopening?: true)
  end
end
