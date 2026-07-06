RSpec.describe AutomatedEmailPreview do
  def preview_for(definition_id, automated_email_id)
    definition = AuthorizationDefinition.find(definition_id)
    automated_email = AuthorizationDefinition::AutomatedEmail.find(automated_email_id)

    described_class.for(definition, automated_email)
  end

  describe '.for' do
    it 'renders a subject and a body for every automated email declared on every definition' do
      AuthorizationDefinition.all.each do |definition|
        definition.automated_emails.each do |automated_email|
          preview = described_class.for(definition, automated_email)

          expect(preview.subject).to be_present, "#{definition.id}/#{automated_email.id}: no subject"
          expect(preview.body).to be_present, "#{definition.id}/#{automated_email.id}: body failed to render"
        end
      end
    end
  end

  describe 'applicant emails' do
    it 'uses the generic template when the definition has no specific one' do
      preview = preview_for('api_entreprise', 'submit_to_applicant')

      expect(preview.subject).to include('Nous accusons réception')
      expect(preview.body).to include('[Nom du demandeur]')
      expect(preview.recipient_emails).to be_nil
    end

    it 'uses the definition specific template when it exists' do
      preview = preview_for('api_cpr_pro_adelie_sandbox', 'approve_to_applicant')

      expect(preview.body).to include('bac à sable')
    end
  end

  describe 'instructors emails' do
    it 'renders the instruction mailer content' do
      preview = preview_for('api_entreprise', 'submit_to_instructors')

      expect(preview.subject).to include('Nouvelle demande')
      expect(preview.body).to include('[Nom du demandeur]')
    end
  end

  describe 'GDPR contacts emails' do
    it 'renders the subject with the contact kind' do
      preview = preview_for('api_entreprise', 'approve_to_responsable_traitement')

      expect(preview.subject).to include('Responsable de traitement')
      expect(preview.body).to include('[Prénom du responsable de traitement]')
    end
  end

  describe 'DGFIP APIM emails' do
    it 'renders the approve notification with the stage label' do
      preview = preview_for('api_cpr_pro_adelie_sandbox', 'approve_to_dgfip_apim')

      expect(preview.subject).to include('Nouvelle habilitation')
      expect(preview.body).to include('BAS')
      expect(preview.recipient_emails).to be_an(Array)
    end
  end

  describe 'HubEE administrateur métier emails' do
    it 'renders the CertDc onboarding email' do
      preview = preview_for('hubee_cert_dc', 'approve_to_hubee_administrateur_metier_cert_dc')

      expect(preview.subject).to include('administrateur local HubEE')
      expect(preview.body).to include('CertDc')
    end
  end

  describe 'FranceConnect emails' do
    it 'targets the FranceConnect partners support' do
      preview = preview_for('api_particulier', 'approve_to_france_connect')

      expect(preview.recipient_emails).to eq(['support.partenaires@franceconnect.gouv.fr'])
      expect(preview.body).to include('[Périmètre de données]')
    end
  end
end
