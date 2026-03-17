RSpec.describe DataProvider do
  describe 'validations' do
    subject { build(:data_provider) }

    it 'validates presence of slug when name is also blank' do
      subject.slug = nil
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:slug]).to be_present
    end

    it 'validates presence of name' do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to be_present
    end

    it 'validates presence of link' do
      subject.link = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:link]).to be_present
    end

    it 'validates uniqueness of slug' do
      create(:data_provider, slug: 'test-slug')
      subject.slug = 'test-slug'
      expect(subject).not_to be_valid
      expect(subject.errors[:slug]).to be_present
    end

    describe 'link format validation' do
      it 'accepts valid URLs' do
        valid_urls = [
          'https://www.example.gouv.fr',
          'http://example.gouv.fr',
          'https://example.gouv.fr/path/to/page',
        ]

        valid_urls.each do |url|
          subject.link = url
          expect(subject).to be_valid, "Expected #{url} to be valid"
        end
      end

      it 'rejects invalid URLs' do
        invalid_urls = ['not a url', 'ftp://example.com', 'example', '']

        invalid_urls.each do |url|
          subject.link = url
          expect(subject).not_to be_valid, "Expected #{url} to be invalid"
        end
      end
    end

    describe 'logo attachment' do
      it 'attaches placeholder logo when logo is purged before validation' do
        provider = build(:data_provider)
        provider.logo.purge
        expect(provider).to be_valid
        expect(provider.logo).to be_attached
      end

      it 'validates logo content type' do
        provider = build(:data_provider)
        provider.logo.attach(io: StringIO.new('content'), filename: 'test.txt', content_type: 'text/plain')
        expect(provider).not_to be_valid
      end

      it 'accepts valid image types' do
        %w[image/png image/jpeg image/svg+xml].each do |content_type|
          provider = build(:data_provider)
          provider.logo.attach(io: StringIO.new('content'), filename: 'test.png', content_type:)
          expect(provider).to be_valid, "Expected #{content_type} to be valid"
        end
      end
    end
  end

  describe 'callbacks' do
    describe '#set_slug_from_name' do
      it 'generates slug from name when slug is blank' do
        provider = described_class.new(name: 'Mon API', link: 'https://mon-api.fr')
        provider.valid?
        expect(provider.slug).to eq('mon-api')
      end

      it 'does not override existing slug' do
        provider = described_class.new(name: 'Mon API', slug: 'custom-slug', link: 'https://mon-api.fr')
        provider.valid?
        expect(provider.slug).to eq('custom-slug')
      end
    end

    describe '#attach_placeholder_logo' do
      it 'attaches city-hall.svg when no logo is provided' do
        provider = described_class.new(name: 'Mon API', link: 'https://mon-api.fr')
        provider.valid?
        expect(provider.logo).to be_attached
        expect(provider.logo.content_type).to eq('image/svg+xml')
        expect(provider.logo.filename.to_s).to eq('city-hall.svg')
      end

      it 'keeps existing logo when one is already attached' do
        provider = build(:data_provider)
        original_filename = provider.logo.filename.to_s
        provider.valid?
        expect(provider.logo.filename.to_s).to eq(original_filename)
      end
    end
  end

  describe '#authorization_definitions' do
    let!(:dgfip_provider) { create(:data_provider, :dgfip) }

    it 'returns authorization definitions for this provider' do
      definitions = dgfip_provider.authorization_definitions

      expect(definitions).to be_all { |d| d.provider.slug == 'dgfip' }
    end
  end

  describe '#reporters' do
    subject { provider.reporters }

    let(:provider) { create(:data_provider, :dgfip) }

    let!(:valid_users) do
      [
        create(:user, :reporter, authorization_request_types: %w[api_impot_particulier api_hermes]),
        create(:user, :instructor, authorization_request_types: %w[api_hermes]),
      ]
    end
    let!(:invalid_users) do
      [
        create(:user, :reporter, authorization_request_types: %w[api_entreprise]),
      ]
    end

    it { is_expected.to match_array(valid_users) }
  end

  describe '#instructors' do
    subject { provider.instructors }

    let(:provider) { create(:data_provider, :dgfip) }
    let!(:valid_users) do
      [
        create(:user, :instructor, authorization_request_types: %w[api_impot_particulier api_hermes]),
        create(:user, :instructor, authorization_request_types: %w[api_hermes]),
      ]
    end
    let!(:invalid_users) do
      [
        create(:user, :reporter, authorization_request_types: %w[api_hermes]),
        create(:user, :reporter, authorization_request_types: %w[api_entreprise]),
      ]
    end

    it { is_expected.to match_array(valid_users) }
  end
end
