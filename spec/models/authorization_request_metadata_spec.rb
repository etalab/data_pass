RSpec.describe AuthorizationRequestMetadata do
  subject(:metadata) { described_class.new(content) }

  def errors_of(metadata)
    metadata.validate
    metadata.errors.map { |error| [error.options[:key], error.attribute, error.type] }
  end

  context 'with scalar values within limits' do
    let(:content) { { 'campagne' => 'migration-editeur-x', 'lot' => 3, 'prioritaire' => false, 'ratio' => 0.5 } }

    it { is_expected.to be_valid }
  end

  context 'with exactly 20 keys, a 40 characters key and a 500 characters value' do
    let(:content) do
      (1..18).to_h { |index| ["cle_#{index}", 'valeur'] }
        .merge('a' * 40 => 'valeur', 'longue' => 'v' * 500)
    end

    it { is_expected.to be_valid }
  end

  context 'when it is not an object' do
    let(:content) { %w[campagne] }

    it { expect(errors_of(metadata)).to eq([[nil, :content, :not_an_object]]) }
  end

  context 'with 21 keys' do
    let(:content) { (1..21).to_h { |index| ["cle_#{index}", 'valeur'] } }

    it { expect(errors_of(metadata)).to eq([[nil, :content, :too_long]]) }
  end

  context 'with a 41 characters key' do
    let(:content) { { 'a' * 41 => 'valeur' } }

    it { expect(errors_of(metadata)).to eq([['a' * 41, :key, :too_long]]) }
  end

  context 'with a key containing spaces or accents' do
    let(:content) { { 'date de création' => 'valeur' } }

    it { expect(errors_of(metadata)).to eq([['date de création', :key, :invalid]]) }
  end

  context 'with a nested value' do
    let(:content) { { 'source' => { 'canal' => 'api' }, 'lots' => [1, 2], 'vide' => nil } }

    it { expect(errors_of(metadata)).to eq([['source', :value, :not_scalar], ['lots', :value, :not_scalar], ['vide', :value, :not_scalar]]) }
  end

  context 'with a non-finite number' do
    let(:content) { { 'lot' => Float::INFINITY, 'ratio' => Float::NAN } }

    it { expect(errors_of(metadata)).to eq([['lot', :value, :not_scalar], ['ratio', :value, :not_scalar]]) }
  end

  context 'with a 501 characters value' do
    let(:content) { { 'commentaire' => 'v' * 501 } }

    it { expect(errors_of(metadata)).to eq([['commentaire', :value, :too_long]]) }
  end

  it 'carries the limit for the error messages' do
    expect(described_class.new({ 'commentaire' => 'v' * 501 }).tap(&:validate).errors.first.options[:count]).to eq(500)
  end
end
