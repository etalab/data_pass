RSpec.describe 'Authorization requests instruction access' do
  let(:user) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }

  before do
    sign_in(user)
  end

  context 'when user wants to access an authorization request' do
    subject(:visit_authorization_request_instruction) do
      get instruction_authorization_request_path(authorization_request)

      response
    end

    context 'when user is an instructor for this authorization request' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise) }

      it 'can access the instruction' do
        visit_authorization_request_instruction

        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is not an instructor for this authorization request' do
      let(:authorization_request) { create(:authorization_request, :api_particulier) }

      it_behaves_like 'an unauthorized access'
    end
  end

  context 'when user wants to validate an authorization request' do
    subject(:visit_authorization_request_approval_instruction) do
      get new_instruction_authorization_request_approval_path(authorization_request)

      response
    end

    context 'when authorization is in instruction' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }

      it 'can access the page' do
        visit_authorization_request_approval_instruction

        expect(response).to have_http_status(:success)
      end
    end

    context 'when authorization is validated' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

      it_behaves_like 'an unauthorized access'
    end
  end

  context 'when user wants to request changes an authorization request' do
    subject(:visit_request_changes_on_authorization_request_instruction) do
      get new_instruction_authorization_request_request_change_path(authorization_request)

      response
    end

    context 'when authorization is in instruction' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }

      it 'can access the page' do
        visit_request_changes_on_authorization_request_instruction

        expect(response).to have_http_status(:success)
      end
    end

    context 'when authorization is in request changes state' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :changes_requested) }

      it_behaves_like 'an unauthorized access'
    end
  end
end
