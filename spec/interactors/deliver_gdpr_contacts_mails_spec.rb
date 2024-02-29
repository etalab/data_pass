RSpec.describe DeliverGDPRContactsMails do
  subject { described_class.call(authorization_request:) }

  describe '#call' do
    context 'when no GDPR contact' do
      let(:authorization_request) { create(:authorization_request) }

      it 'does not deliver any emails to RGPD contacts' do
        AuthorizationExtensions::GDPRContacts::NAMES.each do |contact|
          expect(GDPRContactMailer).not_to receive(contact)
        end

        expect(subject).to be_truthy
      end
    end

    context 'when all GDPR contacts' do
      let(:authorization_request) { create(:authorization_request, :api_particulier, fill_all_attributes: true) }

      it 'delivers emails to RGPD contacts' do
        AuthorizationExtensions::GDPRContacts::NAMES.each do |contact|
          contact_mailer = instance_double(ActionMailer::MessageDelivery)
          allow(GDPRContactMailer).to receive(contact).and_return(contact_mailer)

          expect(contact_mailer).to receive(:deliver_later)
        end

        expect(subject).to be_truthy
      end
    end
  end
end
