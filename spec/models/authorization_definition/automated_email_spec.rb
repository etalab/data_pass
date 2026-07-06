RSpec.describe AuthorizationDefinition::AutomatedEmail do
  describe '.find' do
    it 'returns the automated email matching the id' do
      automated_email = described_class.find('submit_to_applicant')

      expect(automated_email.id).to eq('submit_to_applicant')
      expect(automated_email.event).to eq('submit')
      expect(automated_email.recipient).to eq('applicant')
    end

    it 'exposes the HubEE kind for administrateur métier emails' do
      automated_email = described_class.find('approve_to_hubee_administrateur_metier_cert_dc')

      expect(automated_email.hubee_kind).to eq('cert_dc')
    end

    it 'raises for an unknown id' do
      expect {
        described_class.find('unknown_email')
      }.to raise_error(KeyError)
    end
  end

  describe 'DEFAULT_IDS' do
    it 'only references known automated emails' do
      described_class::DEFAULT_IDS.each do |id|
        expect(described_class::ALL).to have_key(id)
      end
    end
  end
end
