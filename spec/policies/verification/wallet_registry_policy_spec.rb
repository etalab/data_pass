require 'rails_helper'

RSpec.describe Verification::WalletRegistryPolicy do
  subject(:policy) { described_class.new(UserContext.new(user, 'localhost'), %i[verification wallet_registry]) }

  context 'with the verifier role' do
    let(:user) { create(:user, :wallet_verifier) }

    it { expect(policy.show?).to be true }
  end

  [[], %w[admin], %w[dinum:*:instructor], %w[dinum:*:manager], %w[dinum:registre_wallet:instructor]].each do |roles|
    context "with roles #{roles}" do
      let(:user) { create(:user, roles:) }

      it { expect(policy.show?).to be false }
    end
  end
end
