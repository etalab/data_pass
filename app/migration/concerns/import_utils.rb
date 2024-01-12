module ImportUtils
  def csv(name)
    CSV.foreach(dumps_path("#{name}.csv"), headers: true)
  end

  def dumps_path(name)
    Rails.root.join('app', 'migration', 'dumps', name)
  end

  def log(message)
    print "#{message}\n"
    logger.info(message)
  end

  def logger
    Rails.logger
  end
end
