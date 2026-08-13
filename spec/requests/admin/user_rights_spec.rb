require 'rails_helper'

RSpec.describe 'Admin::UserRights index' do
  let(:admin) { create(:user, :admin) }
  let!(:managed_user) { create(:user, email: 'managed@gouv.fr', roles: %w[dinum:api_entreprise:instructor]) }

  before { sign_in(admin) }

  it 'renders the merged list for an admin over every definition' do
    get admin_user_rights_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('managed@gouv.fr')
  end

  it 'filters by a specific API' do
    create(:user, email: 'other@gouv.fr', roles: %w[dinum:api_particulier:instructor])

    get admin_user_rights_path, params: { filters: { droit: 'api_entreprise' } }

    expect(response.body).to include('managed@gouv.fr')
    expect(response.body).not_to include('other@gouv.fr')
  end
end
