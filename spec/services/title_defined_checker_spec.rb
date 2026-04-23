RSpec.describe TitleDefinedChecker do
  describe '#perform!' do
    context 'when title is present' do
      it 'returns true' do
        checker = described_class.new(
          controller_name: 'test',
          action_name: 'show',
          has_title: true
        )

        expect(checker.perform!).to be true
      end
    end

    context 'when route is whitelisted' do
      before do
        stub_const("#{described_class}::WHITELISTED_ROUTES", %w[pages#home].freeze)
      end

      it 'returns true' do
        checker = described_class.new(
          controller_name: 'pages',
          action_name: 'home',
          has_title: false
        )

        expect(checker.perform!).to be true
      end
    end

    context 'when route is not whitelisted and no title is present' do
      it 'raises TitleNotDefinedError with guidance toward both fix options' do
        checker = described_class.new(
          controller_name: 'test',
          action_name: 'show',
          has_title: false
        )

        expect {
          checker.perform!
        }.to raise_error(described_class::TitleNotDefinedError) { |error|
          expect(error.message).to include('Accessibility/SEO Error: No page title has been defined for the current page (test#show).')
          expect(error.message).to include('set_title!')
          expect(error.message).to include('page_titles')
          expect(error.message).to include('TitleDefinedChecker::WHITELISTED_ROUTES')
        }
      end
    end
  end
end
