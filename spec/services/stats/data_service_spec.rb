require 'rails_helper'

RSpec.describe Stats::DataService do
  let(:date_range) { 1.month.ago.to_date..Date.current }

  describe '#call' do
    context 'when include_breakdowns is true' do
      subject(:service) { described_class.new(date_range: date_range, include_breakdowns: true) }

      it 'includes breakdowns in the result' do
        result = service.call

        expect(result).to have_key(:breakdowns)
        expect(result[:breakdowns]).to be_a(Hash)
      end
    end

    context 'when include_breakdowns is false' do
      subject(:service) { described_class.new(date_range: date_range, include_breakdowns: false) }

      it 'does not include breakdowns in the result' do
        result = service.call

        expect(result).not_to have_key(:breakdowns)
      end

      it 'includes volume data' do
        result = service.call

        expect(result).to have_key(:volume)
      end

      it 'includes durations data' do
        result = service.call

        expect(result).to have_key(:durations)
      end
    end

    context 'when include_breakdowns is not specified' do
      subject(:service) { described_class.new(date_range: date_range) }

      it 'defaults to including breakdowns' do
        result = service.call

        expect(result).to have_key(:breakdowns)
      end
    end
  end
end
