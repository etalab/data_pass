RSpec.describe MessageMailer do
  describe '#to_applicant' do
    let(:mail) { described_class.with(message:).to_applicant }
    let(:message) { create(:message) }

    it 'sends the email to the applicant associated to authorization request message' do
      expect(mail.to).to eq([message.authorization_request.applicant.email])
    end

    it 'renders valid template' do
      expect(mail.body.encoded).to match('un nouveau message')
    end
  end

  describe '#to_instructors' do
    let(:mail) { described_class.with(message:).to_instructors }
    let(:message) { create(:message) }

    let!(:first_instructor) { create(:user, :instructor) }
    let!(:second_instructor) { create(:user, :instructor) }

    it 'sends the email to the instructors' do
      expect(mail.to).to contain_exactly(first_instructor.email, second_instructor.email)
    end

    it 'renders valid template' do
      expect(mail.body.encoded).to match('un nouveau message')
    end
  end
end
