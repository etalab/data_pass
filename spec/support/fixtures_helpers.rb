module FixturesHelpers
  def fixture_path(path)
    File.join(File.dirname(__FILE__), '..', 'fixtures', path)
  end

  def read_fixture(path)
    File.read(fixture_path(path))
  end

  def read_json_fixture(path)
    JSON.parse(read_fixture(path))
  end
end
