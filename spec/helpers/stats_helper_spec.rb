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
end
