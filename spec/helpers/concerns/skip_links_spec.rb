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
    it 'returns the default skip links' do
      expect(default_skip_links).to include('Menu', 'Pied de page')
    end
  end

  describe '#skip_links_content' do
    context 'when skip_links content is defined' do
      before do
        allow(self).to receive(:content_for?).with(:skip_links).and_return(true)
        allow(self).to receive(:content_for).with(:skip_links).and_return('<li><a href="#custom">Custom Link</a></li>')
      end

      it 'returns the custom skip links' do
        expect(skip_links_content).to include('Custom Link')
      end
    end

    context 'when skip_links content is not defined' do
      before do
        allow(self).to receive(:content_for?).with(:skip_links).and_return(false)
      end

      context 'when in test environment' do
        before do
          allow(Rails.env).to receive(:test?).and_return(true)
        end

        context 'with a non-whitelisted page' do
          before do
            allow(self).to receive_messages(
              controller_path: 'test_controller',
              action_name: 'test_action'
            )
            allow(self).to receive(:content_for?).with(:content_skip_link_text).and_return(false)
            allow(self).to receive(:validate_skip_links_in_test!).and_raise(
              SkipLinksImplementedChecker::SkipLinksNotDefinedError, 'No skip links defined for this page (test_controller#test_action). Use content_for(:skip_links) to define skip links or define them in a view-specific helper.'
            )
          end

          it 'raises an error' do
            expect { skip_links_content }.to raise_error(SkipLinksImplementedChecker::SkipLinksNotDefinedError, /No skip links defined for this page/)
          end
        end

        context 'with a whitelisted page' do
          before do
            allow(self).to receive_messages(
              controller_path: 'authorization_requests',
              action_name: 'show'
            )
            allow(self).to receive(:content_for?).with(:content_skip_link_text).and_return(false)
            allow(self).to receive_messages(validate_skip_links_in_test!: true)
          end

          it 'returns the default skip links' do
            expect(skip_links_content).to include('Menu', 'Pied de page', 'Aller au contenu')
          end
        end
      end

      context 'when not in test environment' do
        before do
          allow(Rails.env).to receive(:test?).and_return(false)
          allow(self).to receive(:content_for?).with(:skip_links).and_return(false)
          allow(self).to receive(:content_for?).with(:content_skip_link_text).and_return(false)
        end

        it 'returns the default skip links' do
          expect(skip_links_content).to include('Menu', 'Pied de page', 'Aller au contenu')
        end
      end
    end
  end

  describe '#validate_skip_links_in_test!' do
    it 'returns true for whitelisted pages' do
      allow(self).to receive_messages(controller_path: 'authorization_requests', action_name: 'show')
      expect(validate_skip_links_in_test!).to be true
    end

    it 'returns false for non-whitelisted pages' do
      allow(self).to receive_messages(controller_path: 'non_existent', action_name: 'show')
      expect { validate_skip_links_in_test! }.to raise_error(SkipLinksImplementedChecker::SkipLinksNotDefinedError)
    end
  end
end
