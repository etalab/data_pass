RSpec.describe AuthorizationRequest::APIImpotParticulier, type: :model do
  describe 'scopes validation of revenue years ' do
    subject { build(:authorization_request, :api_impot_particulier_editeur, scopes: scopes) }

    context 'with revenue years scope selected' do
      let(:scopes) { %w[dgfip_annee_n_moins_1] }

      it { is_expected.to be_valid }
    end

    context 'without any revenue years scope selected' do
      let(:scopes) { %w[dgfip_indiIFI] }

      it { is_expected.not_to be_valid }
    end
  end

  describe '' do

  end
end
