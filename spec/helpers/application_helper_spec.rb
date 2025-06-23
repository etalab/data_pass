require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#skip_link' do
    it 'renders a list item with a link to an anchor' do
      result = helper.send(:skip_link, 'Test Link', 'test-anchor')

      expect(result).to be_a(ActiveSupport::SafeBuffer)
      expect(result).to have_css('li')
      expect(result).to have_link('Test Link', href: '#test-anchor', class: 'fr-link')
    end

    it 'escapes HTML in the text' do
      result = helper.send(:skip_link, '<script>alert("xss")</script>', 'test-anchor')

      expect(result).to be_a(ActiveSupport::SafeBuffer)
      expect(result).to have_css('li')
      expect(result).to have_link('alert("xss")', href: '#test-anchor', class: 'fr-link')
      expect(result).not_to include('<script>')
    end

    it 'correctly handles non-string anchor values' do
      result = helper.send(:skip_link, 'Numeric Link', 123)

      expect(result).to be_a(ActiveSupport::SafeBuffer)
      expect(result).to have_link('Numeric Link', href: '#123', class: 'fr-link')
    end
  end

  describe '#default_skip_links' do
    it 'returns the default skip links' do
      result = helper.default_skip_links

      expect(result).to be_a(ActiveSupport::SafeBuffer)
      expect(result).to have_link('Menu', href: '#header')
      expect(result).to have_link('Pied de page', href: '#footer')
    end
  end

  describe '#skip_links_content' do
    context 'when skip_links content is defined' do
      before do
        allow(helper).to receive(:content_for?).with(:skip_links).and_return(true)
        allow(helper).to receive(:content_for).with(:skip_links).and_return('<li><a href="#custom">Custom Link</a></li>'.html_safe)
      end

      it 'returns the custom skip links' do
        expect(helper.skip_links_content).to include('Custom Link')
      end
    end

    context 'when skip_links content is not defined' do
      before do
        allow(helper).to receive(:content_for?).with(:skip_links).and_return(false)
      end

      context 'when in test environment' do
        before do
          allow(Rails.env).to receive(:test?).and_return(true)
        end

        context 'with a non-whitelisted page' do
          before do
            allow(helper).to receive(:whitelisted_for_default_skip_links?).and_return(false)
          end

          it 'raises an error' do
            expect { helper.skip_links_content }.to raise_error(RuntimeError, /No skip links defined for this page/)
          end
        end

        context 'with a whitelisted page' do
          before do
            allow(helper).to receive(:whitelisted_for_default_skip_links?).and_return(true)
          end

          it 'returns the default skip links' do
            expect(helper.skip_links_content).to have_link('Menu', href: '#header')
            expect(helper.skip_links_content).to have_link('Pied de page', href: '#footer')
          end
        end
      end

      context 'when not in test environment' do
        before do
          allow(Rails.env).to receive(:test?).and_return(false)
        end

        it 'returns the default skip links' do
          expect(helper.skip_links_content).to have_link('Menu', href: '#header')
          expect(helper.skip_links_content).to have_link('Pied de page', href: '#footer')
        end
      end
    end
  end

  describe '#whitelisted_for_default_skip_links?' do
    it 'returns true for whitelisted pages' do
      allow(helper).to receive_messages(controller_name: 'authorization_requests', action_name: 'show')
      expect(helper.whitelisted_for_default_skip_links?).to be true
    end

    it 'returns false for non-whitelisted pages' do
      allow(helper).to receive_messages(controller_name: 'non_existent', action_name: 'show')
      expect(helper.whitelisted_for_default_skip_links?).to be false
    end
  end
end
