RSpec.describe Subdomain do
  describe '.all' do
    it 'returns a list of all subdomains, each with at least one authorization definition' do
      expect(described_class.all).to be_all { |a| a.is_a? Subdomain }
      expect(described_class.all.map(&:authorization_definitions)).to be_all(&:present?)
    end
  end

  describe '.find_for_authorization_definition' do
    subject(:subdomain) { described_class.find_for_authorization_definition(authorization_definition) }

    context 'when authorization definition is linked to a subdomain' do
      let(:authorization_definition) { AuthorizationDefinition.find('api_entreprise') }

      it 'returns the subdomain linked to the authorization request' do
        expect(subdomain.id).to eq(described_class.find('api-entreprise').id)
      end
    end

    context 'when authorization request is not linked to a subdomain' do
      let(:authorization_definition) { AuthorizationDefinition.find('api_scolarite') }

      it 'returns nil' do
        expect(subdomain).to be_nil
      end
    end
  end
end
