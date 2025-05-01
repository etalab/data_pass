RSpec.describe RedirectFromV1Controller do
  describe 'GET #show' do
    subject(:redirect_from_v1) { get :show, params: { id: } }

    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    context 'when the authorization exists' do
      let(:authorization) { create(:authorization) }
      let(:id) { authorization.id }

      it 'redirects to the authorization path' do
        expect(redirect_from_v1).to redirect_to(authorization_path(authorization.slug))
      end
    end

    context 'when the authorization does not exist' do
      context 'when the authorization request exists' do
        let(:authorization_request) { create(:authorization_request) }
        let(:id) { authorization_request.id }

        it 'redirects to the authorization request path' do
          expect(redirect_from_v1).to redirect_to(authorization_request_path(authorization_request))
        end
      end

      context 'when the authorization request does not exist' do
        let(:id) { 'non_existent_id' }

        it 'raises ActiveRecord::RecordNotFound' do
          expect { redirect_from_v1 }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
