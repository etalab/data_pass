RSpec.describe DataProvider do
  describe '.all' do
    subject { described_class.all }

    it 'works' do
      expect(described_class.all).to be_all { |a| a.is_a? DataProvider }
    end
  end

  describe '#reporters' do
    subject { described_class.find('dgfip').reporters }

    let!(:valid_users) do
      [
        create(:user, :reporter, authorization_request_types: %w[api_impot_particulier api_hermes]),
        create(:user, :instructor, authorization_request_types: %w[api_hermes]),
      ]
    end

    let!(:invalid_users) do
      [
        create(:user, :reporter, authorization_request_types: %w[api_entreprise]),
      ]
    end

    it { is_expected.to match_array(valid_users) }
  end

  describe '#instructors' do
    subject { described_class.find('dgfip').instructors }

    let!(:valid_users) do
      [
        create(:user, :instructor, authorization_request_types: %w[api_impot_particulier api_hermes]),
        create(:user, :instructor, authorization_request_types: %w[api_hermes]),
      ]
    end

    let!(:invalid_users) do
      [
        create(:user, :reporter, authorization_request_types: %w[api_hermes]),
        create(:user, :reporter, authorization_request_types: %w[api_entreprise]),
      ]
    end

    it { is_expected.to match_array(valid_users) }
  end
end
