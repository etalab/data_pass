RSpec.describe AuthorizationRequest::APIImpotParticulier, type: :model do
  subject { build(:authorization_request, :api_impot_particulier_editeur, scopes: scopes) }

  describe 'scopes validation of revenue years ' do
    context 'with revenue years scope selected' do
      let(:scopes) { %w[dgfip_annee_n_moins_1] }

      it { is_expected.to be_valid }
    end

    context 'without any revenue years scope selected' do
      let(:scopes) { %w[dgfip_indiIFI] }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'validation of exclusive years scope combination' do
    context 'with exclusive years scope combination' do
      let(:scopes) { %w[dgfip_annee_n_moins_1 dgfip_annee_n_moins_2] }

      it { is_expected.to be_valid }
    end

    context 'with invalid exclusive years scope combination' do
      let(:scopes) { %w[dgfip_annee_n_moins_2_si_indispo_n_moins_1 dgfip_annee_n_moins_1] }

      it { is_expected.not_to be_valid }
    end
  end
end
