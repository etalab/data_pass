RSpec.shared_examples 'a mail whose html part mirrors its text part' do
  it 'is sent as multipart text and html' do
    expect(mail.mime_type).to eq('multipart/alternative')
  end

  it 'shows the same content in its html part as in its text part' do
    text = mail.text_part.body.decoded
    html = Nokogiri::HTML(mail.html_part.body.decoded).at('body').text

    expect(html.squish).to eq(text.squish)
  end
end
