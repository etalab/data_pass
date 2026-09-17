RSpec.describe PublicIpAddressValidator do
  subject { PublicIpAddressValidatable.new }

  before do
    stub_const('PublicIpAddressValidatable', Class.new do
      include ActiveModel::Validations

      attr_accessor :adresse_ip_publique

      validates :adresse_ip_publique, public_ip_address: true
    end)
  end

  describe 'adresses acceptées' do
    it 'accepte une adresse IPv4 publique' do
      subject.adresse_ip_publique = '192.0.2.10'

      expect(subject).to be_valid
    end

    it 'accepte une adresse IPv6 publique' do
      subject.adresse_ip_publique = '2001:db8::1'

      expect(subject).to be_valid
    end

    it 'accepte une plage CIDR IPv4' do
      subject.adresse_ip_publique = '192.0.2.0/24'

      expect(subject).to be_valid
    end

    it 'accepte une plage CIDR IPv6' do
      subject.adresse_ip_publique = '2001:db8::/32'

      expect(subject).to be_valid
    end

    it 'accepte une plage exprimée avec un masque décimal' do
      subject.adresse_ip_publique = '192.0.2.0/255.255.255.0'

      expect(subject).to be_valid
    end

    it 'accepte plusieurs adresses séparées par des virgules' do
      subject.adresse_ip_publique = '192.0.2.10, 198.51.100.4'

      expect(subject).to be_valid
    end

    it 'accepte plusieurs adresses séparées par des points-virgules' do
      subject.adresse_ip_publique = '192.0.2.10;198.51.100.4'

      expect(subject).to be_valid
    end

    it 'accepte plusieurs adresses séparées par des sauts de ligne' do
      subject.adresse_ip_publique = "192.0.2.10\n198.51.100.0/24"

      expect(subject).to be_valid
    end

    it 'laisse la valeur vide à la validation de présence' do
      subject.adresse_ip_publique = ''

      expect(subject).to be_valid
    end
  end

  describe 'adresses refusées' do
    it 'refuse une adresse IPv4 incomplète' do
      subject.adresse_ip_publique = '192.0.2'

      expect(subject).not_to be_valid
    end

    it 'refuse un octet hors bornes' do
      subject.adresse_ip_publique = '999.1.1.1'

      expect(subject).not_to be_valid
    end

    it 'refuse un préfixe impossible' do
      subject.adresse_ip_publique = '192.0.2.10/33'

      expect(subject).not_to be_valid
    end

    it 'refuse du texte libre' do
      subject.adresse_ip_publique = 'la plage de notre hébergeur'

      expect(subject).not_to be_valid
    end

    it 'refuse une adresse privée' do
      %w[10.0.0.1 172.16.0.5 192.168.1.1 fd00::1].each do |adresse|
        subject.adresse_ip_publique = adresse

        expect(subject).not_to be_valid
      end
    end

    it 'refuse une adresse de loopback' do
      %w[127.0.0.1 ::1].each do |adresse|
        subject.adresse_ip_publique = adresse

        expect(subject).not_to be_valid
      end
    end

    it 'refuse une adresse de lien local' do
      subject.adresse_ip_publique = '169.254.1.1'

      expect(subject).not_to be_valid
    end

    it 'refuse une plage couvrant tout internet' do
      %w[0.0.0.0/0 ::/0].each do |adresse|
        subject.adresse_ip_publique = adresse

        expect(subject).not_to be_valid
      end
    end

    it 'refuse une liste dont une seule entrée est invalide' do
      subject.adresse_ip_publique = '192.0.2.10, 10.0.0.1'

      expect(subject).not_to be_valid
    end

    it 'affiche un message d’erreur explicite' do
      subject.adresse_ip_publique = '10.0.0.1'
      subject.valid?

      expect(subject.errors.full_messages.join).to include('doit être une adresse IP publique')
    end
  end
end
