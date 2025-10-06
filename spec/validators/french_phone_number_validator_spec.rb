class FrenchPhoneNumberValidatable
  include ActiveModel::Validations

  attr_accessor :phone_number

  validates :phone_number, french_phone_number: true
end

class FrenchMobilePhoneValidatable
  include ActiveModel::Validations

  attr_accessor :phone_number

  validates :phone_number, french_phone_number: { mobile: true }
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

      it 'accepts French Polynesia landline numbers (+689 4[0-9])' do
        valid_numbers = [
          '+689 40 12 34',
          '+689401234',
          '+689-41-23-45',
          '+689.49.56.78'
        ]

        valid_numbers.each do |number|
          subject.phone_number = number
          expect(subject).to be_valid, "Expected '#{number}' to be valid"
        end
      end

      it 'accepts Réunion and Mayotte numbers (+262)' do
        valid_numbers = [
          '+262 26 12 34 56',
          '+26226123456',
          '+262-69-12-34-56',
          '+262.26.11.22.33'
        ]

        valid_numbers.each do |number|
          subject.phone_number = number
          expect(subject).to be_valid, "Expected '#{number}' to be valid"
        end
      end

      it 'accepts Saint-Pierre-et-Miquelon numbers (+508)' do
        valid_numbers = [
          '+508 41 23 45',
          '+508412345',
          '+508-55-12-34',
          '+508.41.12.34'
        ]

        valid_numbers.each do |number|
          subject.phone_number = number
          expect(subject).to be_valid, "Expected '#{number}' to be valid"
        end
      end

      it 'accepts Wallis-et-Futuna numbers (+681)' do
        valid_numbers = [
          '+681 12 34 56',
          '+681123456',
          '+681-12-34-56',
          '+681.12.34.56'
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

  describe 'mobile phone formats (France Connect mobile)' do
    let(:mobile_subject) { FrenchMobilePhoneValidatable.new }

    it 'accepts mainland France mobile numbers (06/07 and +33 6/7)' do
      [
        '06 12 34 56 78',
        '07-98-76-54-32',
        '06.66.77.88.99',
        '+33 6 12 34 56 78',
        '+33-7-98-76-54-32',
        '+33.7.11.22.33.44'
      ].each do |number|
        mobile_subject.phone_number = number
        expect(mobile_subject).to be_valid, "Expected '#{number}' to be valid as a mobile number"
      end
    end

    it 'accepts overseas mobile numbers for DOM (590/594/596)' do
      [
        '+590 6 12 34 56 78',
        '+594-7-12-34-56-78',
        '+596.6.11.22.33.44'
      ].each do |number|
        mobile_subject.phone_number = number
        expect(mobile_subject).to be_valid, "Expected '#{number}' to be valid as a mobile number"
      end
    end

    it 'accepts Réunion and Mayotte mobile numbers (+262)' do
      [
        '+262 6 12 34 56',
        '+262-7-12-34-56',
        '+262.6.11.22.33'
      ].each do |number|
        mobile_subject.phone_number = number
        expect(mobile_subject).to be_valid, "Expected '#{number}' to be valid as a mobile number"
      end
    end

    it 'accepts Saint-Pierre-et-Miquelon mobile numbers (+508)' do
      [
        '+508 71 23 45',
        '+508-72-12-34',
        '+508.75.11.22'
      ].each do |number|
        mobile_subject.phone_number = number
        expect(mobile_subject).to be_valid, "Expected '#{number}' to be valid as a mobile number"
      end
    end

    it 'accepts Wallis-et-Futuna mobile numbers (+681)' do
      [
        '+681 12 34 56',
        '+681-98-76-54',
        '+681.11.22.33'
      ].each do |number|
        mobile_subject.phone_number = number
        expect(mobile_subject).to be_valid, "Expected '#{number}' to be valid as a mobile number"
      end
    end

    it 'accepts New Caledonia mobile numbers (+687)' do
      [
        '+687 12 34 56',
        '+687-98-76-54',
        '+687.11.22.33'
      ].each do |number|
        mobile_subject.phone_number = number
        expect(mobile_subject).to be_valid, "Expected '#{number}' to be valid as a mobile number"
      end
    end

    it 'accepts French Polynesia mobile numbers (+689 87/89)' do
      [
        '+689 87 12 34',
        '+689-89-98-76',
        '+689.87.65.43'
      ].each do |number|
        mobile_subject.phone_number = number
        expect(mobile_subject).to be_valid, "Expected '#{number}' to be valid as a mobile number"
      end
    end

    it 'rejects landlines when mobile format is required' do
      [
        '01 23 45 67 89',
        '+33 1 23 45 67 89',
        '+689 4 12 34'
      ].each do |number|
        mobile_subject.phone_number = number
        expect(mobile_subject).not_to be_valid, "Expected '#{number}' to be invalid as a mobile number"
      end

      mobile_subject.phone_number = '01 23 45 67 89'
      expect(mobile_subject).not_to be_valid
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
