# frozen_string_literal: true

RSpec.describe MaintenanceBanner do
  let(:config) do
    {
      start: Time.zone.parse('2026-04-23T14:00:00+02:00'),
      end: Time.zone.parse('2026-04-23T19:30:00+02:00'),
      title: 'Maintenance ProConnect ce soir à 18h',
      description: 'Une opération de maintenance aura lieu ce soir.'
    }
  end

  before { allow(described_class).to receive(:config).and_return(config) }

  describe '.active?' do
    subject { described_class.active? }

    context 'when current time is within the window' do
      before { travel_to(Time.zone.parse('2026-04-23T16:00:00+02:00')) }

      it { is_expected.to be true }
    end

    context 'when current time is before the window' do
      before { travel_to(Time.zone.parse('2026-04-23T13:59:00+02:00')) }

      it { is_expected.to be false }
    end

    context 'when current time is after the window' do
      before { travel_to(Time.zone.parse('2026-04-23T19:31:00+02:00')) }

      it { is_expected.to be false }
    end

    context 'when current date is not the maintenance day' do
      before { travel_to(Time.zone.parse('2026-04-22T16:00:00+02:00')) }

      it { is_expected.to be false }
    end
  end

  describe '.title' do
    it { expect(described_class.title).to eq('Maintenance ProConnect ce soir à 18h') }
  end

  describe '.description' do
    it { expect(described_class.description).to be_present }
  end
end
