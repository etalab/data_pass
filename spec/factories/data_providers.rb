FactoryBot.define do
  sequence(:data_provider_slug) { |n| "provider_#{n}" }

  factory :data_provider do
    slug { generate(:data_provider_slug) }
    name { 'Test Provider' }
    link { 'https://test-provider.gouv.fr' }

    initialize_with { DataProvider.find_or_initialize_by(slug: slug) }

    after(:build) do |data_provider|
      data_provider.logo.attach(
        io: Rails.root.join('spec/fixtures/files/dinum.png').open,
        filename: 'dinum.png',
        content_type: 'image/png'
      )
    end

    trait :dgfip do
      slug { 'dgfip' }
      name { 'DGFIP' }
      link { 'https://api.gouv.fr/producteurs/dgfip' }
    end

    trait :dinum do
      slug { 'dinum' }
      name { 'DINUM' }
      link { 'https://www.numerique.gouv.fr/' }
    end
  end
end
