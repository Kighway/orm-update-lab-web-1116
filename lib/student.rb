require_relative "../config/environment.rb"
require 'pry'

class Student
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade, :id

  def initialize (name , grade)
    @name = name
    @grade = grade
    @id = nil
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE students (
          id INTEGER PRIMARY KEY,
          name TEXT,
          grade INTEGER
        );
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
        DROP TABLE students
        ;
      SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      sql_update = <<-SQL
        UPDATE students
        SET name = ?, grade = ?
        WHERE id = #{id}
      SQL
      DB[:conn].execute(sql_update, name, grade)
    else
      sql_save = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql_save, name, grade)
      sql_id = <<-SQL
        SELECT last_insert_rowid() FROM students
      SQL
      @id = DB[:conn].execute(sql_id).flatten.first
    end
  end

  def self.create (name, grade)
    new(name, grade).save
  end

  def self.new_from_db(attributes)
    id, name, grade = attributes[0], attributes[1], attributes[2]
    student = new(name , grade)
    student.id= id
    student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
    SQL
    new_from_db(DB[:conn].execute(sql, name).flatten)
  end

  def update
    save
  end

end
