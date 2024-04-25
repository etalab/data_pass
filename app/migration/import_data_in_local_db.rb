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
            created_at DATETIME,
            raw_data TEXT
          );
          create index authorization_request_id_index on events (authorization_request_id);
        ",
        insert_statement: "insert into events (id, authorization_request_id, created_at, raw_data) values (?, ?, ?, ?)",
        insert_data: ->(row) { [row['id'], row['enrollment_id'], row['created_at'], row.to_a.to_json] }
      },
      'team_members' => {
        table: "
          create table team_members (
            id INTEGER PRIMARY KEY,
            authorization_request_id INTEGER,
            email TEXT,
            raw_data TEXT
          );
          create index authorization_request_id_index on team_members (authorization_request_id);
          create index authorization_request_email_index on team_members (email);
        ",
        insert_statement: "insert into team_members (id, authorization_request_id, email, raw_data) values (?, ?, ?, ?)",
        insert_data: ->(row) { [row['id'], row['enrollment_id'], row['email'], row.to_a.to_json] }
      },
      'enrollments' => {
        table: "
          create table enrollments (
            id INTEGER PRIMARY KEY,
            target_api TEXT,
            status TEXT,
            copied_from_enrollment_id INTEGER,
            raw_data TEXT
          );
          create index enrollment_id_index on enrollments (id);
          create index enrollment_target_api_index on enrollments (target_api);
        ",
        insert_statement: "insert into enrollments (id, target_api, status, copied_from_enrollment_id, raw_data) values (?, ?, ?, ?, ?)",
        insert_data: ->(row) { [row['id'], row['target_api'], row['status'], row['copied_from_enrollment_id'], row.to_a.to_json] }
      },
      'snapshots' => {
        table: "
          create table snapshots (
            id INTEGER PRIMARY KEY,
            enrollment_id INTEGER,
            created_at DATETIME,
            raw_data TEXT
          );
          create index snapshot_enrollment_id_index on snapshots (enrollment_id);
        ",
        insert_statement: "insert into snapshots (id, enrollment_id, created_at, raw_data) values (?, ?, ?, ?)",
        insert_data: ->(row) { [row['id'], row['item_id'], row['created_at'], row.to_a.to_json] },
      },
      'snapshot_items' => {
        table: "
          create table snapshot_items (
            id INTEGER PRIMARY KEY,
            snapshot_id INTEGER,
            created_at DATETIME,
            raw_data TEXT
          );
          create index snapshot_item_snapshot_id_index on snapshots_items (snapshot_id);
        ",
        insert_statement: "insert into snapshot_items (id, snapshot_id, created_at, raw_data) values (?, ?, ?, ?)",
        insert_data: ->(row) { [row['id'], row['snapshot_id'], row['created_at'], row.to_a.to_json] }
      },
      'documents' => {
        table: "
          create table documents (
            id INTEGER PRIMARY KEY,
            enrollment_id INTEGER,
            raw_data TEXT
          );
          create index document_enrollment_id_index on documents (enrollment_id);
        ",
        insert_statement: "insert into documents (id, enrollment_id, raw_data) values (?, ?, ?)",
        insert_data: ->(row) { [row['id'], row['attachable_id'], row.to_a.to_json] }
      }
    }
  end

  def delete_db_file!
    FileUtils.rm_f(table_path)
    @database = nil
  end
end
