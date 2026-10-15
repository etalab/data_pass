RSpec.describe AuthorizationRequest::Resana do
  subject(:authorization_request) { build(:authorization_request, :resana, fill_all_attributes: true) }

  it 'is submittable once both steps and terms are filled' do
    expect(authorization_request).to be_valid(:submit)
  end

  it 'requires the data protection officer email' do
    authorization_request.delegue_protection_donnees_email = nil

    expect(authorization_request).not_to be_valid(:submit)
    expect(authorization_request.errors[:delegue_protection_donnees_email]).to be_present
  end

  it 'requires Resana terms of service to be accepted' do
    authorization_request.terms_of_service_accepted = false

    expect(authorization_request).not_to be_valid(:submit)
    expect(authorization_request.errors[:base]).to be_present
  end

  it 'requires the data protection officer to be informed' do
    authorization_request.data_protection_officer_informed = false

    expect(authorization_request).not_to be_valid(:submit)
  end
end
