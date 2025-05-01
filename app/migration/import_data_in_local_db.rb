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

      next if definition[:condition].present? && !definition[:condition].call
      database.execute('drop table ' + name.to_s) if definition[:delete_db_before_import]

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
      'users' => {
        table: "
          CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            uid TEXT,
            email TEXT,
            raw_data TEXT
          );
          create unique index users_id_index on users (id);
        ",
        insert_statement: "INSERT INTO users (id, uid, email, raw_data) VALUES (?, ?, ?, ?)",
        insert_data: ->(row) { [row['id'], row['uid'], row['email'], row.to_a.to_json] },
      },
      'events' => {
        table: "
          create table events (
            id INTEGER PRIMARY KEY,
            user_id INTEGER,
            authorization_request_id INTEGER,
            created_at DATETIME,
            raw_data TEXT
          );
          create index authorization_request_events_user_id_index on events (user_id);
          create index authorization_request_events_authorization_request_id_index on events (authorization_request_id);
        ",
        insert_statement: "insert into events (id, user_id, authorization_request_id, created_at, raw_data) values (?, ?, ?, ?, ?)",
        insert_data: ->(row) { [row['id'], row['user_id'], row['enrollment_id'], row['created_at'], row.to_a.to_json] }
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
            user_id INTEGER,
            copied_from_enrollment_id INTEGER,
            previous_enrollment_id INTEGER,
            raw_data TEXT
          );
          create index enrollment_id_index on enrollments (id);
          create index enrollment_user_id_index on enrollments (user_id);
          create index enrollment_target_api_index on enrollments (target_api);
          create index enrollment_copied_from_enrollment_id_index on enrollments (copied_from_enrollment_id);
          create index enrollment_previous_enrollment_id_index on enrollments (previous_enrollment_id);
        ",
        insert_statement: "insert into enrollments (id, target_api, status, user_id, copied_from_enrollment_id, previous_enrollment_id, raw_data) values (?, ?, ?, ?, ?, ?, ?)",
        insert_data: ->(row) { [row['id'], row['target_api'], row['status'], row['user_id'], row['copied_from_enrollment_id'], row['previous_enrollment_id'], row.to_a.to_json] }
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
            type TEXT,
            raw_data TEXT
          );
          create index document_enrollment_id_index on documents (enrollment_id);
        ",
        insert_statement: "insert into documents (id, enrollment_id, type, raw_data) values (?, ?, ?, ?)",
        insert_data: ->(row) { [row['id'], row['attachable_id'], row['type'], row.to_a.to_json] }
      },
      'hubee_subscriptions' => {
        table: "
        create table hubee_subscriptions (
          id TEXT PRIMARY KEY,
          siret TEXT,
          raw_data TEXT
        );
        create index hubee_subscription_siret_index on hubee_subscriptions (siret);
        ",
        insert_statement: "insert into hubee_subscriptions (id, siret, raw_data) values (?, ?, ?)",
        insert_data: ->(row) do
          final_row = row.map { |e| [e[0], (JSON.parse(e[1]) rescue e[1])] }.to_h

          [final_row['id'], final_row['subscriber']['companyRegister'], final_row.to_json]
        end,
        # condition: -> { ENV['IMPORT_HUBEE'] == 'true' },
        # delete_db_before_import: true,
      }
    }
  end

  def delete_db_file!
    FileUtils.rm_f(db_path)
    @database = nil
  end
end
