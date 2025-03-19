RSpec.describe HistoricalAuthorizationRequestEventIconComponent, type: :component do
  describe '#call' do
    context "when event_name is 'approve'" do
      it 'renders the correct icon and color class' do
        render_inline(described_class.new(name: 'approve'))

        expect(page).to have_css("i.fr-icon-checkbox-line.fr-text-success[aria-hidden='true']")
      end
    end

    context "when event_name is 'request_changes'" do
      it 'renders the correct icon and color class' do
        render_inline(described_class.new(name: 'request_changes'))

        expect(page).to have_css("i.fr-icon-pencil-line.fr-text-warning[aria-hidden='true']")
      end
    end

    context "when event_name is 'refuse'" do
      it 'renders the correct icon and color class' do
        render_inline(described_class.new(name: 'refuse'))

        expect(page).to have_css("i.fr-icon-close-circle-line.fr-text-error[aria-hidden='true']")
      end
    end

    context "when event_name is 'revoke'" do
      it "renders the same icon and color class as 'refuse'" do
        render_inline(described_class.new(name: 'revoke'))

        expect(page).to have_css("i.fr-icon-close-circle-line.fr-text-error[aria-hidden='true']")
      end
    end

    context 'when event_name is unknown' do
      it 'renders the default icon and color' do
        render_inline(described_class.new(name: 'unknown_event'))

        expect(page).to have_css("i.fr-icon-error-warning-line.fr-text-info[aria-hidden='true']")
      end
    end
  end
end
