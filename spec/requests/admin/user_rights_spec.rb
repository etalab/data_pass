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

  it 'lists a user who holds no role at all' do
    create(:user, email: 'plain@gouv.fr', roles: [])

    get admin_user_rights_path

    expect(response.body).to include('plain@gouv.fr')
    expect(response.body).to include('Aucun rôle')
  end

  it 'filters on the absence of role' do
    create(:user, email: 'plain@gouv.fr', roles: [])

    get admin_user_rights_path, params: { filters: { role: 'without_roles' } }

    expect(response.body).to include('plain@gouv.fr')
    expect(response.body).not_to include('managed@gouv.fr')
  end

  it 'pre-fills the new form from the email carried by the row action' do
    get new_admin_user_right_path, params: { email: 'plain@gouv.fr' }

    expect(response.body).to include('plain@gouv.fr')
  end

  it 'filters by a specific API' do
    create(:user, email: 'other@gouv.fr', roles: %w[dinum:api_particulier:instructor])

    get admin_user_rights_path, params: { filters: { droit: 'api_entreprise' } }

    expect(response.body).to include('managed@gouv.fr')
    expect(response.body).not_to include('other@gouv.fr')
  end
end
