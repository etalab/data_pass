RSpec.describe 'Errors page' do
  it "doesn't raise errors on 404" do
    expect {
      visit '/what-is-love'
    }.not_to raise_error
  end
end
