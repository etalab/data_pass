RSpec.describe 'Errors page' do
  it 'works' do
    expect {
      visit '/what-is-love'
    }.not_to raise_error
  end
end
