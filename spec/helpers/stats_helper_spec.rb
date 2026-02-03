require 'rails_helper'

RSpec.describe StatsHelper do
  describe '#format_duration_seconds' do
    it 'returns nil for nil input' do
      expect(helper.format_duration_seconds(nil)).to be_nil
    end

    it 'clamps durations under 1 minute to 1 minute' do
      expect(helper.format_duration_seconds(45)).to eq('1 minute')
    end

    it 'clamps 1 second to 1 minute' do
      expect(helper.format_duration_seconds(1)).to eq('1 minute')
    end

    it 'formats minutes only' do
      expect(helper.format_duration_seconds(180)).to eq('3 minutes')
    end

    it 'formats 1 minute as singular' do
      expect(helper.format_duration_seconds(60)).to eq('1 minute')
    end

    it 'formats hours only' do
      expect(helper.format_duration_seconds(7200)).to eq('2 heures')
    end

    it 'formats 1 hour as singular' do
      expect(helper.format_duration_seconds(3600)).to eq('1 heure')
    end

    it 'formats days only' do
      expect(helper.format_duration_seconds(172_800)).to eq('2 jours')
    end

    it 'formats 1 day as singular' do
      expect(helper.format_duration_seconds(86_400)).to eq('1 jour')
    end

    it 'formats complex durations showing only the largest unit' do
      seconds = (2 * 86_400) + (3 * 3600) + (15 * 60) + 30
      expect(helper.format_duration_seconds(seconds)).to eq('2 jours')
    end

    it 'formats zero as 1 minute' do
      expect(helper.format_duration_seconds(0)).to eq('1 minute')
    end
  end

  describe '#format_duration_range' do
    it 'returns default message for nil median' do
      expect(helper.format_duration_range(nil, 100)).to eq('de quelques secondes à quelques jours')
    end

    it 'returns default message for nil stddev' do
      expect(helper.format_duration_range(100, nil)).to eq('de quelques secondes à quelques jours')
    end

    it 'shows explicit lower bound when calculated value is valid' do
      median = 10 * 86_400
      stddev = 5 * 86_400

      expect(helper.format_duration_range(median, stddev)).to eq('de 5 jours à 15 jours')
    end

    it 'shows explicit lower bound for normal day-scale ranges' do
      median = 6 * 86_400
      stddev = 2 * 86_400

      expect(helper.format_duration_range(median, stddev)).to eq('de 4 jours à 8 jours')
    end

    it 'uses quelques heures when stddev > median for day-scale' do
      median = 86_400
      stddev = 17 * 86_400

      expect(helper.format_duration_range(median, stddev)).to eq('de quelques heures à 18 jours')
    end

    it 'uses quelques minutes when stddev > median for hour-scale' do
      median = 3600
      stddev = 7200

      expect(helper.format_duration_range(median, stddev)).to eq('de quelques minutes à 3 heures')
    end

    it 'shows explicit lower bound when barely valid for minute-scale' do
      median = 300
      stddev = 120

      expect(helper.format_duration_range(median, stddev)).to eq('de 3 minutes à 7 minutes')
    end
  end
end
