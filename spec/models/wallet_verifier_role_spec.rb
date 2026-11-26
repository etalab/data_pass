require 'rails_helper'

RSpec.describe 'Wallet registry verifier role' do
  def user_with(*roles)
    build(:user, roles:)
  end

  describe ParsedRole, '.valid?' do
    it 'accepts the verifier role on the registry' do
      expect(described_class.valid?('dinum:registre_wallet:verifier')).to be true
    end

    it 'rejects the verifier role elsewhere and as a wildcard' do
      %w[dinum:api_entreprise:verifier dinum:*:verifier wrong:registre_wallet:verifier].each do |role|
        expect(described_class.valid?(role)).to be false
      end
    end
  end

  describe User, '#verifier?' do
    it 'is true with the exact role' do
      expect(create(:user, :wallet_verifier).verifier?).to be true
    end

    it 'is false for every other role, wildcards and admins included' do
      %w[admin dinum:registre_wallet:instructor dinum:registre_wallet:manager dinum:*:manager dinum:*:verifier].each do |role|
        expect(user_with(role).verifier?).to be false
      end
    end

    it 'gives no instruction right' do
      verifier = user_with('dinum:registre_wallet:verifier')

      expect(verifier.reporter?).to be false
      expect(verifier.developer?).to be false
    end
  end

  describe 'instruction emails' do
    it 'are not sent to verifiers' do
      verifier = create(:user, :wallet_verifier)

      expect(AuthorizationDefinition.find('registre_wallet').instructors_or_reporters).not_to include(verifier)
    end
  end
end
