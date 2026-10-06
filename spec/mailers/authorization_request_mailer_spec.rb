require 'rails_helper'

RSpec.describe AuthorizationRequestMailer do
  describe 'html rendering' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).approve
    end

    context 'when there is a custom HTML template for the authorization request kind' do
      let(:authorization_request) { create(:authorization_request, :annuaire_des_entreprises, :validated) }

      it 'renders the custom template which is html' do
        expect(mail.body.encoded).to match('href')
        expect(mail.body.encoded).to match('espace agent')
      end
    end

    context 'when there is a custom text template but no custom HTML template' do
      let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :validated) }

      it 'does not render an HTML part so the custom text is not shadowed by a generic HTML body' do
        expect(mail.html_part).to be_nil
      end
    end

    context 'when there is neither a custom text nor a custom HTML template' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

      it 'renders the generic HTML template' do
        html = decoded_html_body(mail)
        expect(html).to be_present
        expect(html).to match('validée')
        expect(html).to match('consulter')
      end
    end
  end

  describe '#approve' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).approve
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

    it 'sends the email to the applicant' do
      expect(mail.to).to eq([authorization_request.applicant.email])
    end

    it 'renders valid template' do
      expect(decoded_text_body(mail)).to match('a été validée')
    end

    it 'does not include the unsubscribe footer' do
      expect(decoded_text_body(mail)).not_to match('/compte#notifications-section')
    end

    describe 'custom emails' do
      describe 'HubEE CertDC' do
        let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :validated) }

        it 'renders valid custom template' do
          expect(mail.body.encoded).to match('Portail HubEE')
        end
      end

      describe 'HubEE DILA' do
        let(:authorization_request) { create(:authorization_request, :hubee_dila, :validated) }

        it 'renders valid custom template' do
          expect(decoded_text_body(mail)).to match('Portail HubEE')
        end
      end

      describe 'API R2P sandbox' do
        let(:authorization_request) { create(:authorization_request, :api_r2p_sandbox, :validated) }

        it 'renders valid custom template' do
          expect(mail.body.encoded).to match('DGFiP')
        end
      end

      describe 'annuaire des entreprises' do
        let(:authorization_request) { create(:authorization_request, :annuaire_des_entreprises, :validated) }

        it 'renders valid custom template' do
          expect(mail.body.encoded).to match('espace agent')
        end
      end

      describe 'FranceConnect' do
        let(:authorization_request) { create(:authorization_request, :france_connect, :validated) }

        it 'renders valid custom template for new habilitation' do
          text = decoded_text_body(mail)
          expect(text).to match('Votre habilitation a été validée')
          expect(text).to match('Le demandeur et le responsable technique ont accès à un service dédié sur l\'espace partenaires FranceConnect')
          expect(text).to match('espace.partenaires.franceconnect.gouv.fr')
        end
      end
    end
  end

  describe '#refuse' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).refuse
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :refused) }

    it 'sends the email to the applicant' do
      expect(mail.to).to eq([authorization_request.applicant.email])
    end

    it 'renders valid template, with denial reason' do
      text = decoded_text_body(mail)
      expect(text).to match('a été refusée')
      expect(text).to match(authorization_request.denial.reason)
    end
  end

  describe '#revoke' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).revoke
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :revoked) }

    it 'sends the email to the applicant' do
      expect(mail.to).to eq([authorization_request.applicant.email])
    end

    it 'renders valid template' do
      expect(decoded_text_body(mail)).to match('a été révoquée')
    end

    it 'renders HTML part' do
      html = decoded_html_body(mail)
      expect(html).to be_present
      expect(html).to match('révoquée')
    end
  end

  describe '#changes_requested' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).request_changes
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :changes_requested) }

    it 'sends the email to the applicant' do
      expect(mail.to).to eq([authorization_request.applicant.email])
    end

    it 'renders valid template, with modification request reason' do
      text = decoded_text_body(mail)
      expect(text).to match('des modifications')
      expect(text).to match(authorization_request.modification_request.reason)
    end
  end

  describe '#reopening_approve' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).reopening_approve
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

    it 'sends the email to the applicant' do
      expect(mail.to).to eq([authorization_request.applicant.email])
    end

    it 'renders valid template' do
      text = decoded_text_body(mail)
      expect(text).to match('a été validée')
      expect(text).to match('réouverture')
    end

    describe 'FranceConnect' do
      let(:authorization_request) { create(:authorization_request, :france_connect, :validated) }

      it 'renders valid custom template for reopening' do
        text = decoded_text_body(mail)
        expect(text).to match('La mise à jour de votre habilitation a été validée')
        expect(text).to match('demande-modification-fs-fc')
        expect(text).to match('demarches-simplifiees.fr')
      end
    end
  end

  describe '#reopening_refuse' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).reopening_refuse
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :refused) }

    it 'sends the email to the applicant' do
      expect(mail.to).to eq([authorization_request.applicant.email])
    end

    it 'renders valid template, with denial reason' do
      text = decoded_text_body(mail)
      expect(text).to match('a été refusée')
      expect(text).to match('réouverture')
      expect(text).to match(authorization_request.denial.reason)
    end
  end

  describe '#submit' do
    subject(:mail) { described_class.with(authorization_request:).submit }

    context 'when messaging is enabled' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted, last_submitted_at: 1.day.ago) }

      it 'sends the email to the applicant' do
        expect(mail.to).to eq([authorization_request.applicant.email])
      end

      it 'renders valid template with legal content' do
        text = decoded_text_body(mail)
        expect(text).to match('accusons réception')
        expect(text).to match(authorization_request.id.to_s)
        expect(text).to match('CRPA')
      end

      it 'includes the messages url' do
        expect(decoded_text_body(mail)).to match('messagerie')
      end
    end

    context 'when messaging is disabled' do
      let(:authorization_request) { create(:authorization_request, :api_sfip_sandbox, :submitted, last_submitted_at: 1.day.ago) }

      it 'includes the support email' do
        expect(decoded_text_body(mail)).to match(authorization_request.definition.support_email)
      end

      it 'does not include the messages url' do
        expect(decoded_text_body(mail)).not_to match('messagerie')
      end
    end
  end

  describe '#reopening_submit' do
    subject(:mail) { described_class.with(authorization_request:).reopening_submit }

    context 'when messaging is enabled' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :reopened_and_submitted) }

      it 'sends the email to the applicant' do
        expect(mail.to).to eq([authorization_request.applicant.email])
      end

      it 'renders valid template with legal content' do
        text = decoded_text_body(mail)
        expect(text).to match('accusons réception')
        expect(text).to match(authorization_request.id.to_s)
        expect(text).to match('CRPA')
      end

      it 'includes the messages url' do
        expect(decoded_text_body(mail)).to match('messagerie')
      end
    end

    context 'when messaging is disabled' do
      let(:authorization_request) { create(:authorization_request, :api_sfip_sandbox, :reopened_and_submitted) }

      it 'includes the support email' do
        expect(decoded_text_body(mail)).to match(authorization_request.definition.support_email)
      end

      it 'does not include the messages url' do
        expect(decoded_text_body(mail)).not_to match('messagerie')
      end
    end
  end

  describe '#reopening_request_changes' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).reopening_request_changes
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :changes_requested) }

    it 'sends the email to the applicant' do
      expect(mail.to).to eq([authorization_request.applicant.email])
    end

    it 'renders valid template, with modification request reason' do
      text = decoded_text_body(mail)
      expect(text).to match('réouverture')
      expect(text).to match('des modifications')
      expect(text).to match(authorization_request.modification_request.reason)
    end
  end

  describe 'HubEE file retention notice' do
    let(:notice) { 'vous disposerez de 7 jours à compter de cette date pour télécharger le fichier' }
    let(:deletion) { 'Une fois ce délai passé, le fichier sera automatiquement supprimé de HubEE.' }
    let(:habilitation_type) do
      create(:habilitation_type,
        contact_types: ['contact_metier'],
        blocks: [{ 'name' => 'basic_infos' }, { 'name' => 'cnous_data_extraction_criteria' }, { 'name' => 'contacts' }])
    end

    def cnous_authorization_request(*traits)
      create(:authorization_request, *traits, type: habilitation_type.authorization_request_type, form_uid: habilitation_type.slug)
    end

    before do
      AuthorizationDefinition.reset!
      AuthorizationRequestForm.reset!
    end

    after do
      AuthorizationDefinition.reset!
      AuthorizationRequestForm.reset!
    end

    describe '#approve' do
      subject(:mail) { described_class.with(authorization_request:).approve }

      let(:authorization_request) { cnous_authorization_request(:validated) }

      it 'warns the applicant in the text part that the file is deleted from HubEE after 7 days' do
        text = decoded_text_body(mail)

        expect(text).to include("⚠️ Attention : selon la date indiquée dans votre demande pour la réception du fichier, #{notice}.")
        expect(text).to include(deletion)
      end

      it 'warns the applicant in the HTML part, the emoji being hidden from screen readers' do
        html = decoded_html_body(mail)

        expect(html).to include('<span aria-hidden="true">⚠️</span> Attention :')
        expect(html).to include('<strong>7 jours à compter de cette date pour télécharger le fichier</strong>')
        expect(html).to include(deletion)
      end

      it 'keeps the instructor message after the notice' do
        authorization_request.latest_authorization.update!(message: 'Message de l’instructeur')

        text = decoded_text_body(mail)

        expect(text.index(deletion)).to be < text.index('Message de l’instructeur')
      end
    end

    describe '#reopening_approve' do
      subject(:mail) { described_class.with(authorization_request:).reopening_approve }

      let(:authorization_request) { cnous_authorization_request(:validated) }

      it 'warns the applicant in both parts' do
        expect(decoded_text_body(mail)).to include(notice)
        expect(decoded_html_body(mail)).to include(deletion)
      end
    end

    describe '#refuse' do
      subject(:mail) { described_class.with(authorization_request:).refuse }

      let(:authorization_request) { cnous_authorization_request(:refused) }

      it 'does not include the notice' do
        expect(decoded_text_body(mail)).not_to include(deletion)
      end
    end

    describe 'another kind of authorization request' do
      subject(:mail) { described_class.with(authorization_request:).approve }

      let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

      it 'does not include the notice' do
        expect(decoded_text_body(mail)).not_to include(deletion)
        expect(decoded_html_body(mail)).not_to include(deletion)
      end
    end
  end
end
