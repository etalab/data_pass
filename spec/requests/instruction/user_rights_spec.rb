require 'rails_helper'

RSpec.describe 'Instruction::UserRights index' do
  let(:manager) { create(:user, :manager, email: 'zmanager@gouv.fr', authorization_request_types: %w[api_entreprise]) }

  before { sign_in(manager) }

  describe 'GET /instruction/gestion-des-droits/:id/droits' do
    let(:admin_with_role) do
      create(:user, email: 'admin-too@gouv.fr', roles: [
        'admin', 'dinum:api_entreprise:instructor', 'dinum:api_particulier:manager'
      ])
    end

    it 'renders the pairing between each API and its role' do
      get droits_instruction_user_right_path(admin_with_role)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('API Entreprise').and include('Instructeur')
    end

    it 'never betrays the admin role of the target' do
      get droits_instruction_user_right_path(admin_with_role)

      expect(response.body).not_to include('Admin')
    end
  end

  describe 'GET /instruction/gestion-des-droits with filters' do
    let!(:instructor_user) { create(:user, email: 'instructor@gouv.fr', roles: %w[dinum:api_entreprise:instructor]) }
    let!(:developer_user) { create(:user, email: 'developer@gouv.fr', roles: %w[dinum:api_entreprise:developer]) }
    let!(:fd_reporter_user) { create(:user, email: 'fdreporter@gouv.fr', roles: %w[dinum:*:reporter]) }

    it 'offers neither the admin role nor the presence filters to a manager' do
      get instruction_user_rights_path

      expect(response.body).not_to include('value="admin"')
      expect(response.body).not_to include('value="without_roles"')
    end

    it 'renders the list of managed users' do
      get instruction_user_rights_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('instructor@gouv.fr').and include('developer@gouv.fr')
    end

    it 'filters by literal role type' do
      get instruction_user_rights_path, params: { filters: { role: 'instructor' } }

      expect(response.body).to include('instructor@gouv.fr')
      expect(response.body).not_to include('developer@gouv.fr')
    end

    it 'filters by a specific API' do
      get instruction_user_rights_path, params: { filters: { droit: 'api_entreprise' } }

      expect(response.body).to include('instructor@gouv.fr')
      expect(response.body).not_to include('fdreporter@gouv.fr')
    end
  end

  describe 'pagination' do
    before do
      11.times { |index| create(:user, email: format('user%02d@gouv.fr', index), roles: %w[dinum:api_entreprise:reporter]) }
    end

    it 'shows 10 users per page' do
      get instruction_user_rights_path

      expect(response.body).to include('user00@gouv.fr')
      expect(response.body).not_to include('user10@gouv.fr')

      get instruction_user_rights_path, params: { page: 2 }

      expect(response.body).to include('user10@gouv.fr')
    end
  end
end
