RSpec.describe GDPRContactMailer do
  describe '#responsable_traitement' do
    subject(:mail) { described_class.with(authorization_request:).responsable_traitement }

    let(:authorization_request) { create(:authorization_request, :api_droits_cnam, :validated) }

    it 'is sent to the contact' do
      expect(mail.to).to eq([authorization_request.responsable_traitement_email])
    end

    it_behaves_like 'a mail whose html part mirrors its text part'
  end
end
