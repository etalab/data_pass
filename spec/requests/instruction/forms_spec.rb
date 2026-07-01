RSpec.describe 'Instruction::Forms' do
  let(:authorization_definition) { AuthorizationDefinition.find('api_entreprise') }

  describe 'GET /instruction/formulaires/:authorization_definition_id/cas_d_usage' do
    subject(:request) { get instruction_authorization_definition_forms_path(authorization_definition) }

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

  describe 'GET /instruction/formulaires/:authorization_definition_id/cas_d_usage/:id' do
    subject(:request) { get instruction_authorization_definition_form_path(authorization_definition, form) }

    let(:form) { authorization_definition.available_forms.first }

    context 'when user is a reporter on the definition' do
      let(:user) { create(:user, :reporter, authorization_request_types: %w[api_entreprise]) }

      before { sign_in(user) }

      it 'renders the form show page' do
        request

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(form.name)
        expect(response.body).to include('Configuration')
        expect(response.body).not_to include('Modifier')
        expect(response.body).not_to include('Initier une demande pour autrui')
      end
    end

    context 'when user is a manager on the definition' do
      let(:user) { create(:user, :manager, authorization_request_types: %w[api_entreprise]) }

      before { sign_in(user) }

      it 'renders the modifier buttons' do
        request

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Modifier')
      end
    end

    context 'when user is an instructor on the definition' do
      let(:user) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }

      before { sign_in(user) }

      it 'renders the initiate request button' do
        request

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Initier une demande pour autrui')
      end
    end

    context 'when user has no access to the definition' do
      let(:user) { create(:user) }

      before { sign_in(user) }

      it_behaves_like 'an unauthorized access'
    end
  end
end
