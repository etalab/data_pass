RSpec.describe LocalReturnPath do
  subject(:return_path) { Class.new { include LocalReturnPath }.new.send(:local_return_path, path) }

  {
    '/demandes/registre/nouveau' => '/demandes/registre/nouveau',
    '/demandes?etape=2' => '/demandes?etape=2',
    '/demandes?etape=2#bloc' => '/demandes?etape=2'
  }.each do |given, kept|
    context "with #{given}" do
      let(:path) { given }

      it { is_expected.to eq(kept) }
    end
  end

  {
    'https://evil.example/demandes' => 'an absolute URL',
    '//evil.example/demandes' => 'a protocol-relative URL, which the browser opens on evil.example',
    '///evil.example/demandes' => 'extra slashes, which browsers collapse into //evil.example',
    '/\\evil.example/demandes' => 'a backslash, which browsers read as a slash',
    '/demandes <script>' => 'characters that are not allowed in a URL',
    'demandes' => 'a relative path',
    nil => 'no path'
  }.each do |given, reason|
    context "with #{reason} (#{given.inspect})" do
      let(:path) { given }

      it { is_expected.to be_nil }
    end
  end
end
