Quand('un autre fil utilise la base de données juste après ma requête') do
  visit root_path

  connection_taken = Queue.new
  @connection_hand_back = Queue.new
  @other_thread = Thread.new do
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      connection.select_value('SELECT 1')
      connection_taken << true
      @connection_hand_back.pop
    end
  end
  connection_taken.pop
end

Alors('mon compte est toujours visible dans la base de données') do
  expect(User.where(email: @current_user_email)).to exist
ensure
  @connection_hand_back << true
  @other_thread.join
end
