RSpec.describe ProduitsDinumNotifier, type: :notifier do
  it { expect(described_class.superclass).to eq BaseNotifier }

  describe '#approve' do
    subject(:approve) { notifier.approve({}) }

    let(:notifier) { described_class.new(authorization_request) }
    let(:authorization_request) { create(:authorization_request, :produits_dinum, :validated) }

    before { ActiveJob::Base.queue_adapter = :inline }
    after { ActiveJob::Base.queue_adapter = :test }

    it 'transmits the convention in blind copy to the three contacts' do
      approve

      convention_mail = ActionMailer::Base.deliveries.find do |delivery|
        delivery.body.encoded.include?('/conventions/convention_mise_a_disposition_produits_dinum.pdf')
      end

      expect(convention_mail).to be_present
      expect(convention_mail.bcc).to contain_exactly(authorization_request.responsable_traitement_email, authorization_request.delegue_protection_donnees_email, authorization_request.contact_technique_email)
    end
  end
end
