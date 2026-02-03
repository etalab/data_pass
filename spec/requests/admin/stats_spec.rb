require 'rails_helper'

RSpec.describe 'Admin::Stats' do
  let(:user) { create(:user) }
  let(:admin_user) { create(:user, roles: ['admin']) }

  describe 'GET /admin/stats' do
    context 'when user is not authenticated' do
      it 'redirects to root path' do
        get admin_stats_path

        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user is authenticated but not admin' do
      before { sign_in user }

      it 'redirects to dashboard' do
        get admin_stats_path

        expect(response).to redirect_to(dashboard_path)
      end

      it 'sets error flash message' do
        get admin_stats_path

        expect(flash[:error]).to be_present
        expect(flash[:error][:title]).to eq(I18n.t('application.user_not_authorized.title'))
      end
    end

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'returns success' do
        get admin_stats_path

        expect(response).to have_http_status(:success)
      end

      it 'renders the index template' do
        get admin_stats_path

        expect(response).to render_template(:index)
      end
    end
  end
end
