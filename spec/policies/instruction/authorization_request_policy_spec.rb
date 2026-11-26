RSpec.describe Instruction::AuthorizationRequestPolicy do
  subject(:policy) { described_class.new(UserContext.new(user), authorization_request) }

  let(:user) { create(:user, :instructor, authorization_request_types: %i[api_sfip]) }

  describe '#cancel_next_stage?' do
    subject { policy.cancel_next_stage? }

    context 'when production request comes from a validated sandbox' do
      let(:authorization_request) { create(:authorization_request, :api_sfip_production, :submitted) }

      it { is_expected.to be true }
    end

    context 'when production request was created through an editor form' do
      let(:authorization_request) { create(:authorization_request, :api_sfip_editeur, :submitted) }

      it { is_expected.to be false }
    end

    context 'when user is not an instructor for the request type' do
      let(:user) { create(:user, :instructor, authorization_request_types: %i[api_entreprise]) }
      let(:authorization_request) { create(:authorization_request, :api_sfip_production, :submitted) }

      it { is_expected.to be false }
    end
  end

  describe '#moderate?' do
    subject { policy.moderate? }

    context 'when editor request is submitted' do
      let(:authorization_request) { create(:authorization_request, :api_sfip_editeur, :submitted) }

      it { is_expected.to be true }
    end

    context 'when editor request is a first draft' do
      let(:authorization_request) { create(:authorization_request, :api_sfip_editeur, :draft) }

      it { is_expected.to be true }
    end
  end

  describe 'decisions on a wallet registry request' do
    let(:authorization_request) { create(:authorization_request, :registre_wallet, :submitted) }
    let(:user) { create(:user, roles:) }
    let(:decisions) { [policy.approve?, policy.refuse?, policy.request_changes?] }

    [
      %w[dinum:registre_wallet:instructor],
      %w[dinum:registre_wallet:manager],
      %w[dinum:*:instructor],
      %w[dinum:*:manager],
    ].each do |instruction_roles|
      context "with #{instruction_roles.first} only" do
        let(:roles) { instruction_roles }

        it 'shows the request but allows no decision' do
          expect(policy.show?).to be true
          expect(decisions).to all(be false)
        end
      end

      context "with #{instruction_roles.first} and the verifier role" do
        let(:roles) { instruction_roles + %w[dinum:registre_wallet:verifier] }

        it 'allows every decision' do
          expect(decisions).to all(be true)
        end
      end
    end

    context 'with the verifier role and a read access' do
      let(:roles) { %w[dinum:*:reporter dinum:registre_wallet:verifier] }

      it 'allows every decision' do
        expect(decisions).to all(be true)
      end
    end

    context 'with the verifier role only' do
      let(:roles) { %w[dinum:registre_wallet:verifier] }

      it 'keeps the instruction area closed' do
        expect(policy.show?).to be false
        expect(decisions).to all(be false)
      end
    end
  end
end
