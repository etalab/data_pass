require_relative '../../../app/services/skip_links_implemented_checker'

RSpec.describe SkipLinks do
  include described_class
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Context

  describe '#skip_link' do
    it 'renders a list item with a link to an anchor' do
      result = skip_link('Test Link', 'test-anchor')
      expect(result).to be_a(String)
      expect(result).to include('Test Link')
      expect(result).to include('#test-anchor')
    end

    it 'correctly handles non-string anchor values' do
      result = skip_link('Numeric Link', 123)
      expect(result).to include('#123')
    end
  end

  describe '#default_skip_links' do
    it 'returns the default skip links (e.g., header, footer, content)' do
      expect(default_skip_links).to include('Menu', 'Pied de page')
    end
  end

  describe '#skip_links_content' do
    context 'when skip_links content is explicitly defined' do
      before do
        allow(self).to receive(:content_for?).with(:skip_links).and_return(true)
        allow(self).to receive(:content_for).with(:skip_links).and_return('<li><a href="#custom">Custom Link</a></li>')
      end

      it 'returns the custom skip links' do
        expect(skip_links_content).to include('Custom Link')
      end
    end

    context 'when skip_links content is not explicitly defined' do
      before do
        allow(self).to receive(:content_for?).with(:skip_links).and_return(false)
      end

      context 'when in test environment' do
        before do
          allow(Rails.env).to receive(:test?).and_return(true)
        end

        context 'when the page is not listed as whitelisted' do
          before do
            allow(self).to receive_messages(
              controller_path: 'test_controller',
              action_name: 'test_action'
            )
            allow(self).to receive(:content_for?).with(:content_skip_link_text).and_return(false)
            allow(self).to receive(:validate_skip_links_in_test!).and_raise(
              SkipLinksImplementedChecker::SkipLinksNotDefinedError,
              'Accessibility Error: No skip links have been defined for the current page (test_controller#test_action). To ensure proper navigation for keyboard and screen reader users, add skip links by using `content_for(:skip_links)` in your view or defining them through a dedicated helper method.'
            )
          end

          it 'raises SkipLinksNotDefinedError with the appropriate error message' do
            expect { skip_links_content }.to raise_error(
              SkipLinksImplementedChecker::SkipLinksNotDefinedError,
              /Accessibility Error: No skip links have been defined for the current page \(test_controller#test_action\)\. To ensure proper navigation for keyboard and screen reader users, add skip links by using `content_for\(:skip_links\)` in your view or defining them through a dedicated helper method\./
            )
          end
        end

        context 'when the page is listed as whitelisted' do
          before do
            allow(self).to receive_messages(
              controller_path: 'authorization_requests',
              action_name: 'show'
            )
            allow(self).to receive(:content_for?).with(:content_skip_link_text).and_return(false)
            allow(self).to receive_messages(validate_skip_links_in_test!: true)
          end

          it 'returns the default skip links (e.g., header, footer, content)' do
            expect(skip_links_content).to include('Menu', 'Pied de page', 'Aller au contenu')
          end
        end
      end

      context 'when in a non-test environment' do
        before do
          allow(Rails.env).to receive(:test?).and_return(false)
          allow(self).to receive(:content_for?).with(:skip_links).and_return(false)
          allow(self).to receive(:content_for?).with(:content_skip_link_text).and_return(false)
        end

        it 'returns the default skip links (e.g., header, footer, content)' do
          expect(skip_links_content).to include('Menu', 'Pied de page', 'Aller au contenu')
        end
      end
    end
  end

  describe '#validate_skip_links_in_test!' do
    context 'when the current page is whitelisted' do
      before do
        allow(self).to receive_messages(controller_path: 'authorization_requests', action_name: 'show')
      end

      it 'does not raise an error and returns true' do
        expect(validate_skip_links_in_test!).to be true
      end
    end

    context 'when the current page is not whitelisted' do
      before do
        allow(self).to receive_messages(controller_path: 'non_existent', action_name: 'show')
      end

      it 'raises SkipLinksNotDefinedError to highlight missing skip links' do
        expect { validate_skip_links_in_test! }.to raise_error(
          SkipLinksImplementedChecker::SkipLinksNotDefinedError,
          /Accessibility Error: No skip links have been defined for the current page \(non_existent#show\)\. To ensure proper navigation for keyboard and screen reader users, add skip links by using `content_for\(:skip_links\)` in your view or defining them through a dedicated helper method\./
        )
      end
    end
  end
end
