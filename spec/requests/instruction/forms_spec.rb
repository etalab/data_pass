RSpec.describe 'Instruction::Forms' do
  describe 'GET /instruction/formulaires/:authorization_definition_id/cas_d_usage' do
    subject(:request) { get instruction_authorization_definition_forms_path(authorization_definition) }

    let(:authorization_definition) { AuthorizationDefinition.find('api_entreprise') }

    context 'when user is a reporter on the definition' do
      let(:user) { create(:user, :reporter, authorization_request_types: %w[api_entreprise]) }

      before { sign_in(user) }

      it 'renders the forms list' do
        request

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Cas d&#39;usage')
        expect(response.body).to include(authorization_definition.available_forms.first.name)
      end
    end

    context 'when user has no access to the definition' do
      let(:user) { create(:user) }

      before { sign_in(user) }

      it_behaves_like 'an unauthorized access'
    end
  end
end
