RSpec.describe AuthorizationCore::Checkboxes do
  around do |example|
    ServiceProvider.find('entrouvert').apipfc_enabled = true
    example.run
  ensure
    ServiceProvider.find('entrouvert').apipfc_enabled = false
  end

  let(:authorization_request) do
    build(:authorization_request, :api_particulier_entrouvert_publik, :with_france_connect_embedded_fields)
  end

  describe '#skip_extra_checkbox?' do
    context 'when skip method exists and returns true' do
      it 'returns true for fc_alternative_connexion when conditions are not met' do
        authorization_request.modalities = ['params']
        expect(authorization_request.skip_extra_checkbox?(:fc_alternative_connexion)).to be true
      end
    end

    context 'when skip method exists and returns false' do
      it 'returns false for fc_alternative_connexion when conditions are met' do
        expect(authorization_request.skip_extra_checkbox?(:fc_alternative_connexion)).to be false
      end
    end

    context 'when skip method does not exist' do
      it 'returns false' do
        expect(authorization_request.skip_extra_checkbox?(:nonexistent_checkbox)).to be false
      end
    end
  end

  describe '#all_extra_checkboxes_checked?' do
    context 'when fc_alternative_connexion should be checked and is checked' do
      before do
        authorization_request.fc_alternative_connexion = '1'
      end

      it 'returns true' do
        expect(authorization_request.all_extra_checkboxes_checked?).to be true
      end
    end

    context 'when fc_alternative_connexion should be checked but is not checked' do
      before do
        authorization_request.fc_alternative_connexion = '0'
      end

      it 'returns false' do
        expect(authorization_request.all_extra_checkboxes_checked?).to be false
      end
    end

    context 'when fc_alternative_connexion should be skipped' do
      before do
        authorization_request.modalities = ['params']
        authorization_request.fc_alternative_connexion = '0'
      end

      it 'returns true' do
        expect(authorization_request.all_extra_checkboxes_checked?).to be true
      end
    end
  end
end
