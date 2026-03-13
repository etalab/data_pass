require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#linkify_urls' do
    it 'returns empty string for blank text' do
      expect(helper.linkify_urls(nil)).to eq('')
      expect(helper.linkify_urls('')).to eq('')
      expect(helper.linkify_urls('   ')).to eq('')
    end

    it 'returns text unchanged when there is no URL' do
      text = 'Bonjour, ceci est un message sans lien.'
      expect(helper.linkify_urls(text)).to eq(text)
    end

    it 'wraps a single http URL in an anchor tag' do
      text = 'Consultez http://example.com pour plus d\'infos.'
      result = helper.linkify_urls(text)
      expect(result).to include('<a href="http://example.com" target="_blank" rel="noopener">http://example.com</a>')
      expect(result).to include('Consultez ')
      expect(result).to include(' pour plus ')
    end

    it 'wraps a single https URL in an anchor tag' do
      text = 'Voir https://example.com/path'
      result = helper.linkify_urls(text)
      expect(result).to include('<a href="https://example.com/path" target="_blank" rel="noopener">https://example.com/path</a>')
    end

    it 'linkifies multiple URLs' do
      text = 'Lien 1: https://a.com et lien 2: https://b.com'
      result = helper.linkify_urls(text)
      expect(result).to include('<a href="https://a.com" target="_blank" rel="noopener">https://a.com</a>')
      expect(result).to include('<a href="https://b.com" target="_blank" rel="noopener">https://b.com</a>')
    end

    it 'escapes HTML to prevent XSS' do
      text = 'Cliquez <script>alert(1)</script> https://safe.com'
      result = helper.linkify_urls(text)
      expect(result).not_to include('<script>')
      expect(result).to include('&lt;script&gt;')
      expect(result).to include('https://safe.com')
    end

    it 'marks output as html_safe' do
      result = helper.linkify_urls('https://example.com')
      expect(result).to be_html_safe
    end
  end
end
