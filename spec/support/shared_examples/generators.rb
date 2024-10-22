RSpec.shared_context 'with generator', type: :generator do
  destination Rails.root.join('tmp/generator_specs')

  before(:all) do
    prepare_destination
  end
end
