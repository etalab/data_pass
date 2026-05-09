require 'rails_helper'

RSpec.describe Admin::RemoveHabilitationTypeRoles, type: :interactor do
  describe '.call' do
    subject(:result) { described_class.call(habilitation_type:) }

    let(:habilitation_type) { create(:habilitation_type) }
    let(:uid) { habilitation_type.uid }
    let(:data_provider) { habilitation_type.data_provider }

    context 'when users have roles linked to the habilitation type' do
      let!(:instructor) do
        create(:user).tap do |user|
          UserRole.create!(user: user, role: 'instructor', data_provider: data_provider, authorization_definition_id: uid)
          user.grant_role(:instructor, 'api_entreprise')
        end
      end
      let!(:manager) do
        create(:user).tap do |user|
          UserRole.create!(user: user, role: 'manager', data_provider: data_provider, authorization_definition_id: uid)
        end
      end

      it { is_expected.to be_success }

      it 'removes roles linked to the habilitation type' do
        result

        expect(instructor.reload.user_roles.pluck(:authorization_definition_id)).to eq(['api_entreprise'])
        expect(manager.reload.user_roles).to be_empty
      end
    end

    context 'when users have roles from other habilitation types only' do
      let!(:other_user) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }

      it 'does not affect other roles' do
        result

        expect(other_user.reload.user_roles.count).to eq(1)
      end
    end
  end
end
