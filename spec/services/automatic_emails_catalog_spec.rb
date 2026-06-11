RSpec.describe AutomaticEmailsCatalog do
  subject(:catalog) { described_class.new(definition) }

  let(:definition) { AuthorizationDefinition.find('api_entreprise') }

  describe '#build' do
    subject(:emails) { catalog.build }

    it 'returns AutomaticEmailEntry objects' do
      expect(emails).to all(be_a(described_class::AutomaticEmailEntry))
    end

    context 'with APIEntrepriseNotifier (via APIEntreculierNotifier)' do
      it 'includes the submit email to the applicant' do
        expect(emails).to include(have_attributes(event_name: 'submit', recipient_type: :applicant))
      end

      it 'includes the submit email to instructors' do
        expect(emails).to include(have_attributes(event_name: 'submit', recipient_type: :instructors))
      end

      it 'does not include an approve email to the applicant' do
        expect(emails).not_to include(have_attributes(event_name: 'approve', recipient_type: :applicant))
      end

      it 'does not include a refuse email' do
        expect(emails).not_to include(have_attributes(event_name: 'refuse'))
      end
    end

    context 'with a definition using BaseNotifier with GDPR contacts' do
      let(:definition) { AuthorizationDefinition.find('api_scolarite') }

      it 'includes the approve email to the applicant' do
        expect(emails).to include(have_attributes(event_name: 'approve', recipient_type: :applicant))
      end

      it 'includes the refuse email to the applicant' do
        expect(emails).to include(have_attributes(event_name: 'refuse', recipient_type: :applicant))
      end

      it 'includes the GDPR responsable traitement email on approve' do
        expect(emails).to include(have_attributes(event_name: 'approve', recipient_type: :responsable_traitement))
      end

      it 'includes the GDPR delegue protection donnees email on approve' do
        expect(emails).to include(have_attributes(event_name: 'approve', recipient_type: :delegue_protection_donnees))
      end
    end

    context 'with a DGFIP definition' do
      let(:definition) { AuthorizationDefinition.find('api_impot_particulier') }

      before { create(:data_provider, :dgfip) }

      it 'includes the DGFIP APIM email on approve' do
        expect(emails).to include(have_attributes(event_name: 'approve', recipient_type: :dgfip_apim))
      end
    end

    it 'includes a non-empty subject for each email' do
      expect(emails.map(&:subject)).to all(be_present)
    end
  end
end
