module LocalDatabaseUtils
  def database
    @database ||= SQLite3::Database.new(db_path)
  end

  def db_path
    Rails.root.join('app', 'migration', 'dumps', 'data.db')
  end
end
