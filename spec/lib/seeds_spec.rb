RSpec.describe Seeds do
  let(:seeds) { described_class.new }

  describe '#perform' do
    subject(:perform) { seeds.perform }

    before do
      seeds.flushdb
    end

    it 'does not raise error' do
      expect {
        perform
      }.not_to raise_error
    end

    it 'creates a dgfip user' do
      expect {
        perform
      }.to change(User.where(email: 'dgfip@yopmail.com'), :count).by(1)
    end
  end

  describe '#flushdb' do
    subject(:flushdb) { seeds.flushdb }

    it 'does not raise error' do
      expect {
        flushdb
      }.not_to raise_error
    end

    context 'when in production' do
      before do
        allow(Rails).to receive(:env).and_return('production')
      end

      it 'raises error' do
        expect {
          flushdb
        }.to raise_error(StandardError)
      end
    end
  end
end
