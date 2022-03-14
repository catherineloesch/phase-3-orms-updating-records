
require 'sqlite3'
require 'pry'
DB = {:conn => SQLite3::Database.new("songs.db")}

class Song
  attr_accessor :name, :album
  attr_reader :id

  def initialize(id=nil, name, album)
    @id = id
    @name = name
    @album = album
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS songs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      album TEXT;
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS songs;"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO songs (name, album)
    VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.album)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs;")[0][0]
    self
  end

  def self.create(name:, album:)
    song = Song.new(name, album)
    song.save
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM songs WHERE name = ? LIMIT 1;"
    result = DB[:conn].execute(sql, name).first
    Song.new(result[0], result[1], result[2])
  end

  def update
    if self.id
      self.update
    else
      sql = <<-SQL UPDATE songs
      SET name = ?, album = ?
      WHERE id = ?
      SQL

      DB[:conn].execute(sql, self.name, self.album, self.id)
    end
  end

end