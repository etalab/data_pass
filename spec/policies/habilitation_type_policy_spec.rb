RSpec.describe HabilitationTypePolicy do
  let(:instance) { described_class.new(user_context, habilitation_type) }
  let(:user_context) { UserContext.new(user) }
  let(:user) { create(:user, :admin) }
  let(:habilitation_type) { create(:habilitation_type) }

  describe '#index?' do
    subject { instance.index? }

    it { is_expected.to be true }
  end

  describe '#show?' do
    subject { instance.show? }

    it { is_expected.to be true }
  end

  describe '#new?' do
    subject { instance.new? }

    it { is_expected.to be true }
  end

  describe '#create?' do
    subject { instance.create? }

    it { is_expected.to be true }
  end

  describe '#update?' do
    subject { instance.update? }

    context 'when habilitation type has no authorization requests' do
      before do
        allow(habilitation_type).to receive(:authorization_requests_count).and_return(0)
      end

      it { is_expected.to be true }
    end

    context 'when habilitation type has authorization requests' do
      before do
        allow(habilitation_type).to receive(:authorization_requests_count).and_return(1)
      end

      it { is_expected.to be true }
    end
  end

  describe '#edit?' do
    subject { instance.edit? }

    context 'when habilitation type has no authorization requests' do
      before do
        allow(habilitation_type).to receive(:authorization_requests_count).and_return(0)
      end

      it { is_expected.to be true }
    end

    context 'when habilitation type has authorization requests' do
      before do
        allow(habilitation_type).to receive(:authorization_requests_count).and_return(1)
      end

      it { is_expected.to be true }
    end
  end

  describe '#edit_structural_fields?' do
    subject { instance.edit_structural_fields? }

    context 'when habilitation type has no authorization requests' do
      before do
        allow(habilitation_type).to receive(:authorization_requests_count).and_return(0)
      end

      it { is_expected.to be true }
    end

    context 'when habilitation type has authorization requests' do
      before do
        allow(habilitation_type).to receive(:authorization_requests_count).and_return(1)
      end

      it { is_expected.to be false }
    end
  end

  describe '#destroy?' do
    subject { instance.destroy? }

    context 'when habilitation type has no authorization requests' do
      before do
        allow(habilitation_type).to receive(:authorization_requests_count).and_return(0)
      end

      it { is_expected.to be true }
    end

    context 'when habilitation type has authorization requests' do
      before do
        allow(habilitation_type).to receive(:authorization_requests_count).and_return(1)
      end

      it { is_expected.to be false }
    end
  end
end
