require 'rails_helper'

RSpec.describe Admin::RemoveHabilitationTypeRoles, type: :interactor do
  describe '.call' do
    subject(:result) { described_class.call(habilitation_type:) }

    let(:habilitation_type) { create(:habilitation_type) }
    let(:uid) { habilitation_type.uid }
    let(:fd_slug) { habilitation_type.data_provider.slug }

    context 'when users have roles linked to the habilitation type' do
      let!(:instructor) { create(:user, roles: ["#{fd_slug}:#{uid}:instructor", 'dinum:api_entreprise:instructor']) }
      let!(:manager) { create(:user, roles: ["#{fd_slug}:#{uid}:manager"]) }

      it { is_expected.to be_success }

      it 'removes roles linked to the habilitation type' do
        result

        expect(instructor.reload.roles).to eq(['dinum:api_entreprise:instructor'])
        expect(manager.reload.roles).to be_empty
      end
    end

    context 'when users have roles from other habilitation types only' do
      let!(:other_user) { create(:user, roles: ['dinum:api_entreprise:instructor']) }

      it 'does not affect other roles' do
        result

        expect(other_user.reload.roles).to eq(['dinum:api_entreprise:instructor'])
      end
    end
  end
end
