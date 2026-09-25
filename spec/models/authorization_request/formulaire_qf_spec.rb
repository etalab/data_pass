RSpec.describe AuthorizationRequest::FormulaireQF do
  describe '#formulaire_qf?' do
    subject { build(:authorization_request, :formulaire_qf).formulaire_qf? }

    it { is_expected.to be(true) }
  end

  describe '#editor' do
    subject { build(:authorization_request, :formulaire_qf).editor }

    it { is_expected.to be_nil }
  end
end
