require_relative '../../../app/services/skip_links_implemented'

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
              renders_full_html_view?: true,
              controller_name: 'test_controller',
              action_name: 'test_action'
            )
            allow(self).to receive(:request).and_return(instance_double(ActionDispatch::Request, path: '/test'))
            allow(self).to receive(:content_for?).with(:content_skip_link_text).and_return(false)
            allow(self).to receive(:implemented_skip_links_in_test!).and_raise(
              SkipLinksNotDefinedError, 'No skip links defined for this page (test_controller#test_action - /test). Use content_for(:skip_links) to define skip links or define them in a view-specific helper.'
            )
          end

          it 'raises an error' do
            expect { skip_links_content }.to raise_error(SkipLinksNotDefinedError, /No skip links defined for this page/)
          end
        end

        context 'with a whitelisted page' do
          before do
            allow(self).to receive_messages(
              controller_name: 'authorization_requests',
              action_name: 'show'
            )
            allow(self).to receive(:renders_full_html_view?).and_return(true)
            allow(self).to receive(:content_for?).with(:content_skip_link_text).and_return(false)
            allow(self).to receive_messages(request: instance_double(ActionDispatch::Request, path: '/authorization_requests/1'), implemented_skip_links_in_test!: true)
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

  describe '#implemented_skip_links_in_test!' do
    it 'returns true for whitelisted pages' do
      allow(self).to receive_messages(controller_name: 'authorization_requests', action_name: 'show')
      expect(implemented_skip_links_in_test!).to be true
    end

    it 'returns false for non-whitelisted pages' do
      allow(self).to receive_messages(controller_name: 'non_existent', action_name: 'show')
      expect { implemented_skip_links_in_test! }.to raise_error(SkipLinksNotDefinedError)
    end
  end

  describe '#renders_full_html_view?' do
    let(:request) { instance_double(ActionDispatch::Request) }
    let(:response) { instance_double(ActionDispatch::Response) }

    before do
      allow(self).to receive_messages(request: request, response: response)
    end

    context 'when request is HTML and not XHR' do
      before do
        format_double = instance_double(Mime::Type, html?: true)
        allow(request).to receive_messages(format: format_double, xhr?: false)
        allow(response).to receive(:content_type).and_return('text/html; charset=utf-8')
      end

      it 'returns true' do
        expect(renders_full_html_view?).to be true
      end
    end

    context 'when request is XHR' do
      before do
        allow(request).to receive_messages(format: instance_double(Mime::Type, html?: true), xhr?: true)
        allow(response).to receive(:content_type).and_return('text/html; charset=utf-8')
      end

      it 'returns false' do
        expect(renders_full_html_view?).to be false
      end
    end

    context 'when there is an error' do
      before do
        allow(request).to receive(:format).and_raise(StandardError)
        allow(self).to receive(:respond_to?).with(:content_for?).and_return(true)
        allow(self).to receive(:respond_to?).with(:render).and_return(true)
      end

      it 'returns true as fallback' do
        expect(renders_full_html_view?).to be true
      end
    end
  end
end
