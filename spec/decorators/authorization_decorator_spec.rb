RSpec.describe AuthorizationDecorator, type: :decorator do
  describe '#humanized_contact_types_for' do
    subject { authorization.decorate.humanized_contact_types_for(user) }

    let(:user) { build(:user) }
    let(:authorization) { create(:authorization, authorization_request_trait:) }

    before do
      authorization.data['contact_technique_email'] = user.email
    end

    context 'when the form renames the technical contact to RSSI' do
      let(:authorization_request_trait) { :services_cisirh }

      it { is_expected.to eq(['RSSI']) }
    end

    context 'when the form overrides the technical contact title' do
      let(:authorization_request_trait) { :produits_dinum }

      it { is_expected.to eq(['contact référent des outils numériques de l’administration']) }
    end

    context 'when the form keeps the default wording' do
      let(:authorization_request_trait) { :api_particulier }

      it { is_expected.to eq(['contact technique']) }
    end
  end
end
