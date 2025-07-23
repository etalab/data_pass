RSpec.describe SkipLinksImplementedChecker do
  describe '#perform!' do
    context 'when skip links are present' do
      it 'returns true' do
        skip_links_checker = described_class.new(
          controller_name: 'test',
          action_name: 'show',
          has_skip_links: true
        )

        expect(skip_links_checker.perform!).to be true
      end
    end

    context 'when route is whitelisted' do
      it 'returns true' do
        skip_links_checker = described_class.new(
          controller_name: 'pages',
          action_name: 'home',
          has_skip_links: false
        )

        expect(skip_links_checker.perform!).to be true
      end
    end

    context 'when route is not whitelisted and no skip links' do
      it 'raises SkipLinksNotDefinedError' do
        skip_links_checker = described_class.new(
          controller_name: 'test',
          action_name: 'show',
          has_skip_links: false
        )

        expect {
          skip_links_checker.perform!
        }.to raise_error(SkipLinksImplementedChecker::SkipLinksNotDefinedError, /No skip links defined for this page \(test#show\)/)
      end
    end
  end
end
