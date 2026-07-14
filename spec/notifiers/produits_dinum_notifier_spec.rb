RSpec.describe ProduitsDinumNotifier, type: :notifier do
  it { expect(described_class.superclass).to eq BaseNotifier }

  describe '#approve' do
    subject(:approve) { notifier.approve({}) }

    let(:notifier) { described_class.new(authorization_request) }
    let(:authorization_request) { create(:authorization_request, :produits_dinum, :validated) }

    before { ActiveJob::Base.queue_adapter = :inline }
    after { ActiveJob::Base.queue_adapter = :test }

    it 'transmits the convention to the contact référent des outils numériques' do
      approve

      convention_mail = ActionMailer::Base.deliveries.find do |delivery|
        delivery.to == [authorization_request.contact_technique_email]
      end

      expect(convention_mail).to be_present
      expect(convention_mail.body.encoded).to include('/conventions/convention_mise_a_disposition_produits_dinum.pdf')
    end
  end
end
