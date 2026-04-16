require 'rails_helper'

RSpec.describe LinkifyUrlsInterceptor do
  describe '.linkify_html' do
    subject(:result) { described_class.linkify_html(html) }

    context 'when there is no URL' do
      let(:html) { '<p>Bonjour, ceci est un message sans lien.</p>' }

      it 'returns the content unchanged' do
        expect(result).to include('Bonjour, ceci est un message sans lien.')
        expect(result).not_to include('<a href')
      end
    end

    context 'when there is an http URL' do
      let(:html) { "<p>Consultez http://example.com pour plus d'infos.</p>" }

      it 'wraps the URL in an anchor tag' do
        expect(result).to include('<a href="http://example.com" target="_blank" rel="noopener noreferrer">http://example.com</a>')
      end
    end

    context 'when there is an https URL' do
      let(:html) { '<p>Voir https://example.com/path</p>' }

      it 'wraps the URL in an anchor tag' do
        expect(result).to include('<a href="https://example.com/path" target="_blank" rel="noopener noreferrer">https://example.com/path</a>')
      end
    end

    context 'when there are multiple URLs' do
      let(:html) { '<p>Lien 1: https://a.com et lien 2: https://b.com</p>' }

      it 'linkifies all URLs' do
        expect(result).to include('<a href="https://a.com"')
        expect(result).to include('<a href="https://b.com"')
      end
    end

    context 'when a URL has trailing punctuation' do
      let(:html) { '<p>Voir https://example.com.</p>' }

      it 'strips trailing punctuation from the URL' do
        expect(result).to include('href="https://example.com"')
        expect(result).not_to include('href="https://example.com."')
      end
    end

    context 'when a URL is already inside an anchor tag' do
      let(:html) { '<p><a href="https://example.com">https://example.com</a></p>' }

      it 'does not double-linkify' do
        anchors = Nokogiri::HTML(result).css('a')
        expect(anchors.size).to eq(1)
      end
    end

    context 'when text contains HTML special characters' do
      let(:html) { '<p>Cliquez https://safe.com</p>' }

      it 'preserves the URL in an anchor' do
        expect(result).to include('href="https://safe.com"')
      end
    end
  end

  describe '.delivering_email' do
    subject(:mail) do
      described_class.delivering_email(message)
      message
    end

    context 'when the mail has an html part with URLs' do
      let(:message) do
        Mail.new do
          html_part do
            content_type 'text/html; charset=UTF-8'
            body '<html><body><p>Voir https://example.com pour plus d\'infos.</p></body></html>'
          end
        end
      end

      it 'linkifies URLs in the html part' do
        expect(mail.html_part.body.decoded).to include('<a href="https://example.com"')
      end
    end

    context 'when the mail has no html part' do
      let(:message) do
        Mail.new do
          text_part do
            body 'Plain text only'
          end
        end
      end

      it 'does not raise' do
        expect { mail }.not_to raise_error
      end
    end
  end
end
