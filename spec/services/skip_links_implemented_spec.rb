RSpec.describe SkipLinksImplemented do
  describe '#valid!' do
    context 'when skip links are present' do
      it 'returns true' do
        validator = described_class.new(
          controller_name: 'test',
          action_name: 'show',
          has_skip_links: true
        )

        expect(validator.valid!).to be true
      end
    end

    context 'when route is whitelisted' do
      it 'returns true' do
        validator = described_class.new(
          controller_name: 'pages',
          action_name: 'home',
          has_skip_links: false
        )

        expect(validator.valid!).to be true
      end
    end

    context 'when route is not whitelisted and no skip links' do
      it 'raises SkipLinksNotDefinedError' do
        validator = described_class.new(
          controller_name: 'test',
          action_name: 'show',
          request_path: '/test/show',
          has_skip_links: false
        )

        expect { validator.valid! }.to raise_error(
          SkipLinksNotDefinedError,
          %r{No skip links defined for this page \(test#show - /test/show\)}
        )
      end
    end
  end
end
