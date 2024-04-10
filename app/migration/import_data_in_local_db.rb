require 'csv'
require 'sqlite3'

class ImportDataInLocalDb
  include ImportUtils
  include LocalDatabaseUtils

  def perform(delete_db_file: false)
    delete_db_file! if delete_db_file

    definitions.each do |name, definition|
      print "Importing #{name}... "
      time = Time.now

      begin
        database.execute definition[:table]
      rescue SQLite3::SQLException => e
        if e.message.include?('already exists')
          print "Table already exists (error: #{e.message})\n"
          print "Skipping..\n"
          next
        else
          raise
        end
      end

      csv(name).each do |row|
        database.execute(
          definition[:insert_statement],
          definition[:insert_data].call(row)
        )
      end

      print "done (#{Time.now - time}s)\n"
    end
  end

  private

  def definitions
    {
      'events' => {
        table: "
          create table events (
            id INTEGER PRIMARY KEY,
            authorization_request_id INTEGER,
            raw_data TEXT
          );
          create index authorization_request_id_index on events (authorization_request_id);
        ",
        insert_statement: "insert into events (id, authorization_request_id, raw_data) values (?, ?, ?)",
        insert_data: ->(row) { [row['id'], row['enrollment_id'], row.to_a.to_json] }
      },
      'team_members' => {
        table: "
          create table team_members (
            id INTEGER PRIMARY KEY,
            authorization_request_id INTEGER,
            raw_data TEXT
          );
          create index authorization_request_id_index on team_members (authorization_request_id);
        ",
        insert_statement: "insert into team_members (id, authorization_request_id, raw_data) values (?, ?, ?)",
        insert_data: ->(row) { [row['id'], row['enrollment_id'], row.to_a.to_json] }
      },
      'enrollments' => {
        table: "
          create table enrollments (
            id INTEGER PRIMARY KEY,
            target_api TEXT,
            raw_data TEXT
          );
          create index enrollment_id_index on enrollments (id);
          create index enrollment_target_api_index on enrollments (target_api);
        ",
        insert_statement: "insert into enrollments (id, target_api, raw_data) values (?, ?, ?)",
        insert_data: ->(row) { [row['id'], row['target_api'], row.to_a.to_json] }
      }
    }
  end

  def delete_db_file!
    FileUtils.rm_f(table_path)
    @database = nil
  end
end
