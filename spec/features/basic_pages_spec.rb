describe 'Basic pages', type: :feature do
  it 'works' do
    visit '/'

    expect(page).to have_content 'DataPass'
  end
end
