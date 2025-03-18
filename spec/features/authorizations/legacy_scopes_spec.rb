RSpec.describe 'Authorization with legacy scopes' do
  let(:authorization_request) { create(:authorization_request, :api_particulier, :validated, scopes:, applicant: user) }
  let(:user) { create(:user) }
  let(:scopes) { valid_scopes + legacy_scopes }
  let(:valid_scopes) { AuthorizationDefinition.find('api_particulier').scopes.map(&:value).sample(3) }
  let(:legacy_scopes) { %w[legacy_scope_1 legacy_scope_2] }

  before do
    sign_in(user)

    visit authorization_path(authorization_request.latest_authorization)
  end

  it 'displays legacy scopes' do
    legacy_scopes.each do |scope|
      expect(page).to have_content(scope)
    end
  end
end
