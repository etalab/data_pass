require 'rails_helper'

RSpec.describe AuthorizationHeaderComponent, type: :component do
  subject { render_inline(described_class.new(authorization: authorization)) }

  let(:authorization) { create(:authorization) }

  it 'renders the authorization header with correct information' do
    expect(subject.css('h1').text).to include("Habilitation à #{authorization.definition.name}")
    expect(subject.css('p').text).to include(authorization.name)
    expect(subject.css('.fr-badge').text).to include("Habilitation n°#{authorization.id}")
    expect(subject.css('.fr-badge').text).to include(authorization.state)
  end
end
