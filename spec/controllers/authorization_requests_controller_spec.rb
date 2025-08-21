RSpec.describe AuthorizationRequestsController do
  describe 'GET #new' do
    subject(:new_authorization_request) { get :new, params: { definition_id: authorization_definition_id } }

    describe 'when authorization definition exists' do
      let(:authorization_definition_id) { AuthorizationDefinition.all.first.id }

      it { is_expected.to have_http_status(:ok) }
    end

    describe 'when authorization definition does not exist' do
      let(:authorization_definition_id) { 'non_existent_id' }

      it 'raises an ActiveRecord::RecordNotFound error' do
        expect { new_authorization_request }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
