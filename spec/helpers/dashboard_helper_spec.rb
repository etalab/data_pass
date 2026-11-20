RSpec.describe DashboardHelper do
  describe '#dashboard_list_title' do
    let(:wallet_request) { build(:authorization_request, :registre_wallet) }
    let(:api_entreprise_request) { build(:authorization_request, :api_entreprise) }

    it 'speaks of verification when every pending request belongs to the wallet registry' do
      expect(helper.dashboard_list_title('pending', [wallet_request])).to eq('Demandes en cours de vérification')
    end

    it 'names both when the registry request sits among other forms' do
      expect(helper.dashboard_list_title('pending', [wallet_request, api_entreprise_request])).to eq('Demandes en cours d’instruction ou de vérification')
    end

    it 'keeps the shared title for the other forms' do
      expect(helper.dashboard_list_title('pending', [api_entreprise_request])).to eq("Demandes en cours d'instruction")
    end

    it 'keeps the shared title of a list the registry does not rename' do
      expect(helper.dashboard_list_title('draft', [wallet_request, api_entreprise_request])).to eq('Demandes en brouillon')
    end
  end
end
