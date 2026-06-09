require 'rails_helper'

RSpec.describe Instruction::RevokeOauthApplicationsIfNoDeveloperRole, type: :interactor do
  describe '.call' do
    subject(:result) { described_class.call(user:) }

    context 'when the user no longer has any developer role' do
      let(:user) { create(:user, roles: ['dinum:api_entreprise:reporter']) }

      before { create(:oauth_application, owner: user) }

      it 'destroys all their OAuth applications' do
        expect { result }.to change { Doorkeeper::Application.where(owner: user).count }.from(1).to(0)
      end
    end

    context 'when the user still has a developer role' do
      let(:user) { create(:user, roles: ['dinum:api_entreprise:developer']) }

      before { create(:oauth_application, owner: user) }

      it 'preserves their OAuth applications' do
        expect { result }.not_to change { Doorkeeper::Application.where(owner: user).count }
      end
    end

    context 'when the user has no OAuth applications' do
      let(:user) { create(:user, roles: []) }

      it 'succeeds without error' do
        expect(result).to be_success
      end
    end
  end
end
