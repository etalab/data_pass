RSpec.describe InstructorModificationRequest do
  it 'has valid factories' do
    expect(build(:instructor_modification_request)).to be_valid
  end
end
