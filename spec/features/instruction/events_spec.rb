RSpec.describe 'Instruction: habilitation events' do
  let(:user) { create(:user, :instructor) }
  let(:authorization_request) { create(:authorization_request, :api_entreprise, applicant: user) }

  before do
    sign_in(user)

    AuthorizationRequestEvent::NAMES.each_with_index do |event_name, index|
      create(:authorization_request_event, event_name, authorization_request:, created_at: index.days.ago)
    end
  end

  it 'works for all events' do
    expect {
      visit instruction_authorization_request_events_path(authorization_request)
    }.not_to raise_error
  end
end
