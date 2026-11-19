RSpec.describe Atoms::PublicRegistry::EmptyResultsComponent, type: :component do
  {
    no_match: 'Aucune entrée ne correspond. Essayez un autre nom d’organisation.',
    no_match_filtered: 'Aucune entrée ne correspond. Essayez un autre nom d’organisation ou retirez un filtre.',
    no_wallet_entry: 'Aucune organisation n’est encore enregistrée.',
  }.each do |reason, message|
    it "renders the #{reason} message as a plain paragraph" do
      expect(render_inline(described_class.new(reason:))).to have_css('p', exact_text: message)
    end
  end

  it 'rejects an unknown reason' do
    expect { described_class.new(reason: :unknown) }.to raise_error(ArgumentError, /reason must be one of/)
  end
end
