require 'rails_helper'

RSpec.describe WebhooksHelper do
  describe '#webhook_attempt_result_badge' do
    subject(:badge) { helper.webhook_attempt_result_badge(webhook_attempt, size: :sm) }

    context 'when the attempt has been abandoned' do
      let(:webhook_attempt) { build(:webhook_attempt, :abandoned) }

      it 'renders a warning badge' do
        expect(badge).to have_css('.fr-badge.fr-badge--warning', text: 'Abandonné')
      end
    end

    context 'when the attempt succeeded' do
      let(:webhook_attempt) { build(:webhook_attempt) }

      it 'renders a success badge' do
        expect(badge).to have_css('.fr-badge.fr-badge--success', text: 'Succès')
      end
    end

    context 'when the attempt failed without being abandoned' do
      let(:webhook_attempt) { build(:webhook_attempt, :failed) }

      it 'renders an error badge' do
        expect(badge).to have_css('.fr-badge.fr-badge--error', text: 'Échec')
      end
    end
  end
end
