require 'rails_helper'

RSpec.describe LinkInEmailsInterceptor do
  def build_mail(html_body)
    mail = Mail.new
    mail.html_part = Mail::Part.new do
      content_type 'text/html; charset=UTF-8'
      body html_body
    end
    mail
  end

  shared_examples 'linkifies the html part' do |method_name|
    subject(:process) { described_class.public_send(method_name, mail) }

    context 'when there is no html part' do
      let(:mail) { Mail.new }

      it 'does not raise' do
        expect { process }.not_to raise_error
      end
    end

    context 'when the html has no URL' do
      let(:mail) { build_mail('<p>Bonjour, pas de lien ici.</p>') }

      it 'does not add any anchor tag' do
        process
        expect(mail.html_part.decoded).not_to include('<a href=')
      end
    end

    context 'when the html contains a plain URL in text' do
      let(:mail) { build_mail('<p>Consultez https://example.com pour plus d\'infos.</p>') }

      it 'wraps the URL in an anchor tag' do
        process
        html = mail.html_part.decoded
        expect(html).to include('href="https://example.com"')
        expect(html).to include('target="_blank"')
        expect(html).to include('rel="noopener noreferrer"')
      end

      it 'preserves the surrounding text' do
        process
        expect(mail.html_part.decoded).to include('Consultez ')
        expect(mail.html_part.decoded).to include(' pour plus')
      end
    end

    context 'when the URL has trailing punctuation' do
      let(:mail) { build_mail('<p>Voir https://example.com/path.</p>') }

      it 'strips the trailing dot from the href' do
        process
        expect(mail.html_part.decoded).to include('href="https://example.com/path"')
      end

      it 'preserves the trailing dot as text after the link' do
        process
        expect(mail.html_part.decoded).to include('</a>.')
      end
    end

    context 'when the URL is already inside an anchor tag' do
      let(:mail) { build_mail('<a href="https://example.com">https://example.com</a>') }

      it 'does not double-linkify' do
        process
        html = mail.html_part.decoded
        expect(html.scan('<a ').count).to eq(1)
      end
    end
  end

  describe '.delivering_email' do
    it_behaves_like 'linkifies the html part', :delivering_email
  end

  describe '.previewing_email' do
    it_behaves_like 'linkifies the html part', :previewing_email
  end
end
