RSpec.describe AdminChange do
  describe 'validations' do
    it 'is valid with valid attributes' do
      admin_change = build(:admin_change)

      expect(admin_change).to be_valid
    end

    it 'is invalid without public_reason' do
      admin_change = build(:admin_change, public_reason: nil)

      expect(admin_change).not_to be_valid
      expect(admin_change.errors[:public_reason]).to be_present
    end

    it 'is valid without private_reason' do
      admin_change = build(:admin_change, private_reason: nil)

      expect(admin_change).to be_valid
    end

    it 'is invalid without authorization_request' do
      admin_change = build(:admin_change, authorization_request: nil)

      expect(admin_change).not_to be_valid
    end
  end

  describe '#legacy?' do
    it 'returns false' do
      expect(build(:admin_change).legacy?).to be(false)
    end
  end

  describe '#initial?' do
    it 'returns false' do
      expect(build(:admin_change).initial?).to be(false)
    end
  end
end
