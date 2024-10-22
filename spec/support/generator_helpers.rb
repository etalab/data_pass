module GeneratorHelpers
  ROOT_PATH = Rails.root.join('tmp/generator_specs')

  def generator_file(path)
    File.new(File.join(ROOT_PATH, path))
  end

  def import_for_generator(path)
    FileUtils.mkdir_p(File.dirname(File.join(ROOT_PATH, path)))
    FileUtils.cp(Rails.root.join(path), File.join(ROOT_PATH, path))
  end
end
