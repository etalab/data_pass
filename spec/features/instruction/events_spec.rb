RSpec.describe 'Instruction: habilitation events' do
  let(:user) { create(:user, :instructor) }
  let(:authorization_request) { create(:authorization_request, :api_entreprise, applicant: user) }
  let(:event_names_to_display) do
    AuthorizationRequestEvent::NAMES.dup + %w[cancel_reopening_from_instructor]
  end

  before do
    sign_in(user)

    event_names_to_display.each_with_index do |event_name, index|
      create(:authorization_request_event, event_name, authorization_request:, created_at: index.days.ago)
    end

    Bullet.enable = false
  end

  after do
    Bullet.enable = true
  end

  it 'works for all events' do
    expect {
      visit instruction_authorization_request_events_path(authorization_request)
    }.not_to raise_error
  end
end
