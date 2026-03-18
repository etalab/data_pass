RSpec.describe StaticApplicationRecord do
  describe 'cache versioning Redis' do
    let(:model) { AuthorizationDefinition }

    before do
      model.instance_variable_set(:@all, nil)
      model.instance_variable_set(:@cache_version, nil)
    end

    after { model.reset! }

    it 'loads backend only once when version unchanged' do
      expect(AuthorizationDefinition).to receive(:backend).once.and_call_original
      model.all
      model.all
    end

    it 'reloads cache when another worker called reset!' do
      model.all
      saved_version = model.instance_variable_get(:@cache_version)

      model.reset!

      model.instance_variable_set(:@cache_version, saved_version)
      model.instance_variable_set(:@all, [])

      expect(AuthorizationDefinition).to receive(:backend).once.and_call_original
      model.all
    end

    it 'does not reload when version is unchanged' do
      model.all
      expect(AuthorizationDefinition).not_to receive(:backend)
      model.all
    end

    context 'when Redis is unavailable' do
      before do
        allow(Kredis).to receive(:counter).and_raise(Redis::BaseError)
      end

      it 'does not raise' do
        expect { model.all }.not_to raise_error
      end
    end
  end
end
