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
end
