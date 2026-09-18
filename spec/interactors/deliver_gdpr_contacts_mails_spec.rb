RSpec.describe DeliverGDPRContactsMails do
  subject { described_class.call(authorization_request:) }

  describe '#call' do
    context 'when no there is no GDPR contact on authorization request' do
      let(:authorization_request) { create(:authorization_request) }

      AuthorizationExtensions::GDPRContacts::NAMES.each do |gdpr_contact|
        it "does not deliver a notification email to #{gdpr_contact}" do
          expect { subject }.not_to have_enqueued_mail(GDPRContactMailer, gdpr_contact)
        end
      end
    end

    context 'when all GDPR contacts exist on authorization request' do
      let(:authorization_request) { create(:authorization_request, :api_scolarite, fill_all_attributes: true) }

      it 'delivers notification emails to these contacts' do
        expect { subject }.to have_enqueued_mail(GDPRContactMailer, :responsable_traitement)
          .and have_enqueued_mail(GDPRContactMailer, :delegue_protection_donnees)
      end
    end

    context 'when authorization request is an API Entreprise one with a legacy responsable de traitement' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, fill_all_attributes: true) }

      before do
        authorization_request.data['responsable_traitement_email'] = 'responsable@gouv.fr'
        authorization_request.save!
      end

      it 'delivers the notification email to the délégué à la protection des données only' do
        expect { subject }.to have_enqueued_mail(GDPRContactMailer, :delegue_protection_donnees)
      end

      it 'does not deliver the notification email to the responsable de traitement' do
        expect { subject }.not_to have_enqueued_mail(GDPRContactMailer, :responsable_traitement)
      end
    end
  end
end
