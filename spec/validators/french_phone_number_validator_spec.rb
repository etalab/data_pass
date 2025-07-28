class FrenchPhoneNumberValidatable
  include ActiveModel::Validations

  attr_accessor :phone_number

  validates :phone_number, french_phone_number: true
end

RSpec.describe FrenchPhoneNumberValidator do
  subject { FrenchPhoneNumberValidatable.new }

  describe 'valid French phone numbers' do
    context 'with French mobile numbers starting with 0' do
      it 'accepts 0X XX XX XX XX format with spaces' do
        subject.phone_number = '06 12 34 56 78'
        expect(subject).to be_valid
      end

      it 'accepts 0XXXXXXXXX format without spaces' do
        subject.phone_number = '0836656565'
        expect(subject).to be_valid
      end

      it 'accepts different mobile prefixes' do
        %w[06 07].each do |prefix|
          subject.phone_number = "#{prefix} 12 34 56 78"
          expect(subject).to be_valid
        end
      end

      it 'accepts landline numbers' do
        %w[01 02 03 04 05 08 09].each do |prefix|
          subject.phone_number = "#{prefix} 12 34 56 78"
          expect(subject).to be_valid
        end
      end
    end

    context 'with international format +33' do
      it 'accepts +33 X XX XX XX XX format with spaces' do
        subject.phone_number = '+33 6 12 34 56 78'
        expect(subject).to be_valid
      end

      it 'accepts +33XXXXXXXXX format without spaces' do
        subject.phone_number = '+33612345678'
        expect(subject).to be_valid
      end

      it 'accepts different mobile prefixes with +33' do
        %w[6 7].each do |prefix|
          subject.phone_number = "+33 #{prefix} 12 34 56 78"
          expect(subject).to be_valid
        end
      end

      it 'accepts landline numbers with +33' do
        %w[1 2 3 4 5 8 9].each do |prefix|
          subject.phone_number = "+33 #{prefix} 12 34 56 78"
          expect(subject).to be_valid
        end
      end
    end

    context 'with French overseas territories' do
      it 'accepts Guadeloupe, Saint-Martin, Saint-Barthélemy numbers (+590)' do
        valid_numbers = [
          '+590 6 12 34 56 78',
          '+590612345678',
          '+590-6-12-34-56-78',
          '+590.6.12.34.56.78'
        ]

        valid_numbers.each do |number|
          subject.phone_number = number
          expect(subject).to be_valid, "Expected '#{number}' to be valid"
        end
      end

      it 'accepts French Guiana numbers (+594)' do
        valid_numbers = [
          '+594 6 12 34 56 78',
          '+594612345678',
          '+594-6-12-34-56-78',
          '+594.6.12.34.56.78'
        ]

        valid_numbers.each do |number|
          subject.phone_number = number
          expect(subject).to be_valid, "Expected '#{number}' to be valid"
        end
      end

      it 'accepts Martinique numbers (+596)' do
        valid_numbers = [
          '+596 6 12 34 56 78',
          '+596612345678',
          '+596-6-12-34-56-78',
          '+596.6.12.34.56.78'
        ]

        valid_numbers.each do |number|
          subject.phone_number = number
          expect(subject).to be_valid, "Expected '#{number}' to be valid"
        end
      end

      it 'accepts New Caledonia numbers (+687)' do
        valid_numbers = [
          '+687 12 34 56',
          '+687123456',
          '+687-12-34-56',
          '+687.12.34.56'
        ]

        valid_numbers.each do |number|
          subject.phone_number = number
          expect(subject).to be_valid, "Expected '#{number}' to be valid"
        end
      end

      it 'rejects overseas territory numbers with wrong format' do
        invalid_numbers = [
          '+590 0 12 34 56 78',  # 0 is not valid after +590
          '+594 12 34 56 7',     # too short
          '+596 12 34 56 789',   # too long
          '+687 12 34 56 78',    # too long for New Caledonia
          '+687 1 23 45',        # too short for New Caledonia
        ]

        invalid_numbers.each do |number|
          subject.phone_number = number
          expect(subject).not_to be_valid, "Expected '#{number}' to be invalid"
        end
      end
    end

    context 'with different separators' do
      it 'accepts numbers with dashes' do
        valid_numbers = [
          '06-12-34-56-78',
          '06-66-93-20-74',
          '+33-6-12-34-56-78'
        ]

        valid_numbers.each do |number|
          subject.phone_number = number
          expect(subject).to be_valid, "Expected '#{number}' to be valid"
        end
      end

      it 'accepts numbers with dots' do
        valid_numbers = [
          '06.12.34.56.78',
          '06.66.87.34.56',
          '+33.6.12.34.56.78'
        ]

        valid_numbers.each do |number|
          subject.phone_number = number
          expect(subject).to be_valid, "Expected '#{number}' to be valid"
        end
      end

      it 'accepts numbers with mixed separators' do
        valid_numbers = [
          '06  12 34 56 78',
          '06 12  34 56 78',
          '+33  6 12 34 56 78',
          '+33 6  12 34 56 78',
          '06-12 34.56 78',
          '+33.6-12 34-56 78'
        ]

        valid_numbers.each do |number|
          subject.phone_number = number
          expect(subject).to be_valid, "Expected '#{number}' to be valid"
        end
      end
    end
  end

  describe 'invalid French phone numbers' do
    context 'with incorrect formats' do
      it 'rejects numbers with wrong length' do
        invalid_numbers = [
          '06 12 34 56 7',     # too short
          '06 12 34 56 789',   # too long
          '+33 6 12 34 56 7',  # too short
          '+33 6 12 34 56 789' # too long
        ]

        invalid_numbers.each do |number|
          subject.phone_number = number
          expect(subject).not_to be_valid, "Expected '#{number}' to be invalid"
          expect(subject.errors[:phone_number]).to include(I18n.t('activemodel.errors.messages.invalid_french_phone_format'))
        end
      end

      it 'rejects numbers with invalid prefixes' do
        invalid_numbers = [
          '00 12 34 56 78',    # 00 is not valid
          '+33 0 12 34 56 78'  # 0 is not valid after +33
        ]

        invalid_numbers.each do |number|
          subject.phone_number = number
          expect(subject).not_to be_valid, "Expected '#{number}' to be invalid"
        end
      end

      it 'rejects non-numeric characters' do
        invalid_numbers = [
          '06/12/34/56/78',
          '06a12b34c56d78',
          '06#12#34#56#78'
        ]

        invalid_numbers.each do |number|
          subject.phone_number = number
          expect(subject).not_to be_valid, "Expected '#{number}' to be invalid"
        end
      end

      it 'rejects foreign numbers' do
        invalid_numbers = [
          '+1 555 123 4567',   # US number
          '+44 20 7946 0958',  # UK number
          '+49 30 12345678'    # German number
        ]

        invalid_numbers.each do |number|
          subject.phone_number = number
          expect(subject).not_to be_valid, "Expected '#{number}' to be invalid"
        end
      end

      it 'rejects malformed international format' do
        invalid_numbers = [
          '33 6 12 34 56 78',  # missing +
          '0033 6 12 34 56 78' # 0033 instead of +33
        ]

        invalid_numbers.each do |number|
          subject.phone_number = number
          expect(subject).not_to be_valid, "Expected '#{number}' to be invalid"
        end
      end
    end
  end

  describe 'edge cases' do
    it 'accepts blank values (presence validation should be handled separately)' do
      subject.phone_number = nil
      expect(subject).to be_valid

      subject.phone_number = ''
      expect(subject).to be_valid

      subject.phone_number = '   '
      expect(subject).to be_valid
    end

    it 'rejects phone numbers with extreme spacing' do
      subject.phone_number = '0 6 1 2 3 4 5 6 7 8'
      expect(subject).not_to be_valid
    end
  end
end
